import chisel3._
import chisel3.util._

/******************** IP FROM VIVADO ********************/

// class dirty_ram extends BlackBox {
//     val io = IO{new Bundle{
//         val addra = Input(UInt(8.W))
//         val clka  = Input(Clock())
//         val dina  = Input(Bool())
//         val douta = Output(Bool())
//         val wea   = Input(Bool())
//     }}
// }

// class data_ram extends BlackBox {
//     val io = IO{new Bundle{
//         val addra = Input(UInt(8.W))
//         val clka  = Input(Clock())
//         val dina  = Input(UInt(32.W))
//         val douta = Output(UInt(32.W))
//         val wea   = Input(UInt(4.W))
//     }}
// }

// class tagv_ram extends BlackBox {
//     val io = IO{new Bundle{
//         val addra = Input(UInt(8.W))
//         val clka  = Input(Clock())
//         val dina  = Input(UInt(21.W))
//         val douta = Output(UInt(21.W))
//         val wea   = Input(Bool())
//     }}
// }

/******************** IP FROM VIVADO ********************/



class dcache(tagWidth: Int, nrSets: Int, nrLines: Int, offsetWidth: Int) extends Module{
    /***************************IO INTERFACES***************************/

    //cache-pipeline
    val valid           = IO(Input(Bool()))
    val op              = IO(Input(Bool()))
    val index           = IO(Input(UInt(8.W)))      //VIPT
    val tag             = IO(Input(UInt(20.W)))
    val offset          = IO(Input(UInt(4.W)))
    val wstrb           = IO(Input(UInt(4.W)))
    val wdata           = IO(Input(UInt(32.W)))
    val addr_ok         = IO(Output(Bool()))
    val data_ok         = IO(Output(Bool()))
    val rdata           = IO(Output(UInt(32.W)))
    val lstype          = IO(Input(UInt(3.W)))
    val uncached        = IO(Input(Bool()))

    //cache-axi
    val rd_req          = IO(Output(Bool()))
    val rd_type         = IO(Output(UInt(3.W)))
    val rd_addr         = IO(Output(UInt(32.W)))
    val rd_rdy          = IO(Input(Bool()))
    val ret_valid       = IO(Input(Bool()))
    val ret_last        = IO(Input(Bool()))
    val ret_data        = IO(Input(UInt(32.W)))
    val wr_req          = IO(Output(Bool()))
    val wr_type         = IO(Output(UInt(3.W)))
    val wr_addr         = IO(Output(UInt(32.W)))
    val wr_wstrb        = IO(Output(UInt(4.W)))
    val wr_data         = IO(Output(UInt(128.W)))
    val wr_rdy          = IO(Input(Bool()))

    //cache instruction
    val cache_op_en     = IO(Input(Bool()))
    val cache_op        = IO(Input(UInt(3.W)))
    val cache_tag       = IO(Input(UInt(20.W)))
    val cache_index     = IO(Input(UInt(8.W)))
    val cache_offset    = IO(Input(UInt(4.W)))
    val tag_input       = IO(Input(UInt(22.W)))       //data from TagLO/TagHI
    val tag_output      = IO(Output(UInt(22.W)))
    val cache_op_done   = IO(Output(Bool()))

    //debug
    val hit             = IO(Output(Bool()))


    /***************************CACHE OPERATION**************************/

    val cacheOperation      = ListLookup(cache_op, List(0.B, 0.B, 0.B, 0.B, 0.B), MIPS32CacheOp.table)
    val cacheInst_r         = RegInit(0.B)
    val invalidate          = RegInit(0.B)
    val loadTag             = RegInit(0.B)
    val storeTag            = RegInit(0.B)
    val writeBack           = RegInit(0.B)
    val indexOnly           = RegInit(0.B)        //use only index to look up cache
    val waySel              = Wire(UInt(1.W))

    cache_op_done   := 0.U
    tag_output      := 0.U


    /***************************IO INTERFACES***************************/

    val sIdle :: sLookup :: sMiss :: sWriteout :: sReplace :: sRefill :: Nil = Enum(6)

    val setWidth  = log2Ceil(nrSets)
    val lineWidth = log2Ceil(nrLines)
    val dataWidth = 128

    //cache
    val tagv      = VecInit.fill(nrLines)(Module(new tagv_ram()).io)
    val data      = VecInit.fill(nrLines, dataWidth / 32)(Module(new data_ram()).io)

    val dirty     = RegInit(VecInit.fill(2, 256)(0.B))

    //buffer of req
    val req_valid       = RegInit(0.B)
    // val req_addr  = RegInit(0.U(64.W))
    val req_op          = RegInit(0.B)
    val req_uncached    = RegInit(0.B)
    val req_offset      = RegInit(0.U(offsetWidth.W))
    val req_lstype      = RegInit(0.U(3.W))
    val req_set         = RegInit(0.U(setWidth.W))
    val req_tag         = RegInit(0.U(tagWidth.W))
    val req_wstrb_0     = RegInit(0.U(4.W))
    val req_wdata_0     = RegInit(0.U(32.W))

    val req_wdata_1     = RegInit(0.U(32.W))
    val req_wstrb_1     = RegInit(0.U(4.W))
    val req_wline       = RegInit(0.U(lineWidth.W))
    val req_wset        = RegInit(0.U(setWidth.W))
    val req_woffset     = RegInit(0.U(offsetWidth.W))

    val req_rline       = Wire(UInt(lineWidth.W))
    val war_stall       = Wire(Bool())      //write-after-read stall

    val tagv_r          = RegInit(VecInit.fill(nrLines)(0.U((tagWidth+1).W)))
    waySel          := req_tag(0)

    //initialise
    for(i <- 0 until nrLines){
        tagv(i).addra   := req_set
        tagv(i).clka    := clock
        tagv(i).dina    := 0.U
        tagv(i).wea     := 0.U

        for(j <- 0 until (dataWidth / 32)){
            data(i)(j).addra    := req_set
            data(i)(j).clka     := clock
            data(i)(j).dina     := 0.U
            data(i)(j).wea      := 0.U
        }
    }

    hit                 := 0.U
    rdata               := 0x7777.U //MAGIC NUMBER
    addr_ok             := 0.U
    data_ok             := 0.U
    rd_req              := 0.U
    rd_type             := 0.U
    rd_addr             := 0.U
    wr_req              := 0.U
    wr_type             := 0.U
    wr_addr             := 0.U
    wr_wstrb            := 0.U
    wr_data             := 0.U

    req_rline           := 0.U
    /**********************FSM**********************/

    //主状态机
    val state           = RegInit(sIdle)


    val refillIDX_r     = RegInit(0.U(lineWidth.W))
    val refillIDX       = Wire(UInt(lineWidth.W))
    val refillHit       = Wire(Bool())
    val LFSR_result     = RegNext(random.LFSR(16))
    val wr_cnt          = RegInit(0.U(2.W))
    
    refillHit           := 0.U
    refillIDX           := 0.U
    
    switch(state){
        is (sIdle){
            when(cache_op_en){
                state           := sLookup
                req_uncached    := 0.U
                req_op          := 0.U
                req_tag         := cache_tag
                req_set         := cache_index
                cacheInst_r     := cache_op_en
                invalidate      := cacheOperation(0)
                loadTag         := cacheOperation(1)
                storeTag        := cacheOperation(2)
                writeBack       := cacheOperation(3)
                indexOnly       := cacheOperation(4)
                for (i <- 0 until nrLines) {
                    tagv(i).addra := cache_index
                    for (j <- 0 until (dataWidth / 32)) {
                        data(i)(j).addra := cache_index
                    }
                }
            }
            .elsewhen(valid) {
                state           := Mux(uncached, sWriteout, sLookup)
                addr_ok         := 1.U
                req_op          := op
                req_valid       := valid
                req_tag         := tag
                req_set         := index
                req_offset      := offset
                req_uncached    := uncached
                req_lstype      := lstype
                req_wstrb_0     := wstrb
                req_wdata_0     := wdata
                for (i <- 0 until nrLines) {
                    tagv(i).addra := index
                    for (j <- 0 until (dataWidth / 32)) {
                        data(i)(j).addra := index
                    }
                }
            }
        }
        is (sLookup){
            for(i <- 0 until nrLines){
                when((tagv(i).douta(19, 0) === req_tag) && tagv(i).douta(20)){
                    hit         := !req_uncached
                    rdata       := data(i)(req_offset(3, 2)).douta
                    when(!req_op)
                    {
                        req_rline   := i.U
                    }
                    .elsewhen(!cacheInst_r){
                        req_woffset := req_offset
                        req_wset    := req_set
                        req_wline   := i.U
                        req_wstrb_1 := req_wstrb_0
                        req_wdata_1 := req_wdata_0
                    }
                    when(!indexOnly){
                        refillIDX_r := i.U
                    }

                    when(!war_stall & !cacheInst_r)
                    {
                        data_ok     := 1.U
                    }
                }
            }

            for (i <- 0 until nrLines) {
                tagv_r(i)   := tagv(i).douta
            }

            when(cacheInst_r){
                when(indexOnly){
                    state       := MuxCase(sIdle, Seq(
                        (writeBack                      , sWriteout),
                        (invalidate                     , sRefill  ),
                        (loadTag                        , sRefill  ),
                        (storeTag                       , sRefill  ),
                    ))
                    refillIDX_r     := waySel
                }
                .elsewhen(hit){
                    state       := MuxCase(sIdle, Seq(
                        (writeBack                      , sWriteout),
                        (invalidate                     , sRefill)
                    ))
                }
                .otherwise{
                    cache_op_done   := 1.U
                    cacheInst_r     := 0.U
                    invalidate      := 0.U
                    indexOnly       := 0.U
                    writeBack       := 0.U
                    storeTag        := 0.U
                    loadTag         := 0.U
                    state           := sIdle
                }
            }
            .elsewhen(!hit){
                state           := sMiss
            }
            .elsewhen(!war_stall){
                  when(valid)
                  {
                      state           := Mux(uncached, sWriteout, sLookup)
                      addr_ok         := 1.U
                      req_valid       := valid
                      req_uncached    := uncached
                      req_lstype      := lstype
                      req_op          := op
                      req_tag         := tag
                      req_set         := index
                      req_offset      := offset
                      req_wstrb_0     := wstrb
                      req_wdata_0     := wdata
                      for (i <- 0 until nrLines) {
                          tagv(i).addra := index
                          for (j <- 0 until (dataWidth / 32)) {
                              data(i)(j).addra := index
                          }
                      }
                  }.otherwise{
                      req_valid := 0.U
                      state := sIdle
                  }
              }
              .otherwise{
                  state   := sLookup
              }
        }
        is (sMiss){
            state := sWriteout
            for(i <- 0 until nrLines){
                when(!tagv_r(i)(20)){
                    refillHit           := 1.U
                    refillIDX           := i.U
                }
            }
            for(i  <- 0 until nrLines){
                when(tagv_r(i)(19, 0) === req_tag && tagv_r(i)(20)){
                    refillHit           := 1.U
                    refillIDX           := i.U
                }
            }
            when(!refillHit) {
                refillIDX := LFSR_result(lineWidth - 1, 0)
            }
            refillIDX_r := refillIDX
        }
        is (sWriteout){
            state     := sWriteout
            req_rline := refillIDX_r
            when(!req_op && req_uncached){
                state   := sReplace
            }
            .elsewhen(wr_rdy) {
                when(war_stall) {
                    state := sWriteout
                }
                .elsewhen(!req_uncached || writeBack) {
                    state           := sReplace
                    when(dirty(refillIDX_r)(req_set)){
                        wr_req      := 1.U
                        wr_addr     := Cat(Seq(tagv_r(refillIDX_r)(19, 0), req_set, 0.U(4.W)))
                        wr_data     := Cat(Seq(data(refillIDX_r)(3).douta, data(refillIDX_r)(2).douta,
                                data(refillIDX_r)(1).douta, data(refillIDX_r)(0).douta))
                        wr_type     := "b100".U
                        wr_wstrb    := "b1111".U
                    }
                }
                .elsewhen(req_op && req_uncached) {
                    state       := sIdle
                    wr_req      := 1.U
                    wr_addr     := Cat(Seq(req_tag, req_set, req_offset))
                    wr_data     := Cat(0.U(96.W), req_wdata_0)
                    wr_wstrb    := req_wstrb_0
                    wr_type     := req_lstype >> 1.U
                    data_ok     := 1.U
               }
            }
        }
        is (sReplace){
            when(!cacheInst_r){
                state           := sReplace
                rd_req          := Mux(req_op && req_uncached, 0.U,  1.U)
                rd_type         := Mux(req_uncached, req_lstype >> 1.U, "b100".U)
                rd_addr         := Mux(req_uncached, Cat(Seq(req_tag, req_set, req_offset)), Cat(Seq(req_tag, req_set, 0.U(4.W))))
    
                when(rd_rdy){
                    state       := sRefill
                }
            }.otherwise{
                state           := sRefill
            }
        }
        is (sRefill){
            state                       := sRefill
            when(!req_uncached & !cacheInst_r)
            {
                when(ret_valid)
                {
                    wr_cnt                                  := wr_cnt + 1.U
                    data(refillIDX_r)(wr_cnt).dina          := ret_data
                    data(refillIDX_r)(wr_cnt).wea           := 0xF.U
                    when(ret_last)
                    {
                        state                               := sLookup
                        dirty(refillIDX_r)(req_set)         := 0.U
                        tagv(refillIDX_r).wea               := 1.U
                        tagv(refillIDX_r).dina              := Cat(1.B, req_tag)
                    }
                }
            }
            .elsewhen(!cacheInst_r){
                when(ret_valid & ret_last)
                {
                    data_ok                                 := 1.U
                    rdata                                   := ret_data
                    state                                   := sIdle
                    req_valid                               := 0.U
                }
            }.otherwise{
                state                                       := sIdle
                cache_op_done                               := 1.U
                when(loadTag){
                    tag_output                              := Cat(dirty(waySel)(req_set), tagv_r(waySel)(20, 0))
                }
                when(storeTag){
                    tagv(waySel).dina                            := tag_input(20, 0)
                    tagv(waySel).wea                             := 1.U
                    dirty(waySel)(req_set)                       := tag_input(21)
                }
                when(invalidate){
                    when(indexOnly){
                        tagv(waySel).dina                        := 0.U
                        tagv(waySel).wea                         := 1.U
                        dirty(waySel)(req_set)                   := 0.U
                    }.otherwise{
                        tagv(refillIDX_r).dina              := 0.U
                        tagv(refillIDX_r).wea               := 1.U
                        dirty(refillIDX_r)(req_set)         := 0.U
                    }
                }
                cacheInst_r                                 := 0.U
                invalidate                                  := 0.U
                indexOnly                                   := 0.U
                writeBack                                   := 0.U
                storeTag                                    := 0.U
                loadTag                                     := 0.U
            }
        }
    }

    //Write Buffer

    // WriteBuffer States
    val wsIdle :: wsWrite :: wsCleanup :: Nil = Enum(3)
    val wstate       = RegInit(wsIdle)

    val req_woffset_1 = RegInit(0.U(offsetWidth.W))
    val req_wline_1   = RegInit(0.U(lineWidth.W))

    switch(wstate){
        is (wsIdle){
            when(hit & req_op){
                wstate      := wsWrite
            }
        }
        is (wsWrite){
            dirty(req_wline)(req_wset)                      := 1.U
            data(req_wline)(req_woffset(3, 2)).addra        := req_wset
            data(req_wline)(req_woffset(3, 2)).wea          := req_wstrb_1
            data(req_wline)(req_woffset(3, 2)).dina         := req_wdata_1

            req_wline_1                                     := req_wline
            req_woffset_1                                   := req_woffset
            when(hit & req_op){
                wstate      := wsWrite
            }
              .otherwise{
                  wstate      := wsCleanup
              }

        }
        is (wsCleanup){
            wstate          := wsIdle
            when(hit & req_op){
                wstate      := wsWrite
            }
        }
    }

    war_stall               := (wstate === wsWrite || wstate === wsCleanup) && req_valid && !req_uncached && (req_wline === req_rline || req_wline_1 === req_rline) &&
      ((!req_op && state === sLookup && (req_woffset(3, 2) === req_offset(3, 2) || req_woffset_1(3, 2) === req_offset(3, 2))) || (state === sMiss))

    /**********************FSM**********************/
}



