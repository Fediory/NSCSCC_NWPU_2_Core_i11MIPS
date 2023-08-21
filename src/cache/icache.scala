import chisel3._
import chisel3.util._

    /******************** IP FROM VIVADO ********************/ 

class icache(tagWidth: Int, nrSets: Int, nrLines: Int, offsetWidth: Int) extends Module{
    /***************************IO INTERFACES***************************/

    //cache-pipeline
    val valid       = IO(Input(Bool()))
    val op          = IO(Input(Bool()))
    val index       = IO(Input(UInt(8.W)))      //VIPT
    val tag         = IO(Input(UInt(20.W)))
    val offset      = IO(Input(UInt(4.W)))
    val addr_ok     = IO(Output(Bool()))
    val data_ok     = IO(Output(Bool()))
    val rdata       = IO(Output(UInt(32.W)))
    val uncached    = IO(Input(Bool()))

    //cache-axi
    val rd_req      = IO(Output(Bool()))
    val rd_type     = IO(Output(UInt(3.W)))
    val rd_addr     = IO(Output(UInt(32.W)))
    val rd_rdy      = IO(Input(Bool()))
    val ret_valid   = IO(Input(Bool()))
    val ret_last    = IO(Input(Bool()))
    val ret_data    = IO(Input(UInt(32.W)))

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
    val hit         = IO(Output(Bool()))


    /***************************CACHE OPERATION**************************/

    val cacheOperation  =  ListLookup(cache_op, List(0.B, 0.B, 0.B, 0.B, 0.B), MIPS32CacheOp.table)
    val cacheInst_r         = RegInit(0.B)
    val invalidate          = RegInit(0.B)
    val loadTag             = RegInit(0.B)
    val storeTag            = RegInit(0.B)
    val writeBack           = RegInit(0.B)
    val indexOnly           = RegInit(0.B)        //use only index to look up cache
    val fill                = Wire(Bool())
    val waySel              = Wire(UInt(1.W))

    fill            := !indexOnly & invalidate & writeBack
    cache_op_done   := 0.U
    tag_output      := 0.U


    /***************************IO INTERFACES***************************/

    val sIdle :: sLookup :: sMiss :: sReplace :: sRefill :: Nil = Enum(5)

    val setWidth  = log2Ceil(nrSets)
    val lineWidth = log2Ceil(nrLines)
    val dataWidth = 128

    //cache
    val tagv      = VecInit.fill(nrLines)(Module(new tagv_ram()).io)
    val data      = VecInit.fill(nrLines, dataWidth / 32)(Module(new data_ram()).io)

    //buffer of req
    val req_valid       = RegInit(0.B)
    val req_op          = RegInit(0.B)
    val req_uncached    = RegInit(0.B)
    val req_offset      = RegInit(0.U(offsetWidth.W))
    val req_set         = RegInit(0.U(setWidth.W))
    val req_tag         = RegInit(0.U(tagWidth.W))
    
    val req_rline       = Wire(UInt(lineWidth.W))
    
    waySel              := req_tag(0)

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

    req_rline           := 0.U
    /**********************FSM**********************/

    //主状态机
    val state           = RegInit(sIdle)
    val lineBuf         = RegInit(0.U(dataWidth.W))


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
                state := Mux(uncached, sMiss, sLookup)
                addr_ok := 1.U
                req_op := op
                req_valid := valid
                req_tag := tag
                req_set := index
                req_offset := offset
                req_uncached := uncached
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
                    
                    when(!indexOnly){
                        refillIDX_r := i.U    
                    }
                    data_ok     := !cacheInst_r
                }

            }
            when(cacheInst_r){
                when(indexOnly){
                    state       := sRefill
                    refillIDX_r := waySel
                }.elsewhen(fill){
                    state       := sMiss
                }
                .elsewhen(hit){
                    state       := MuxCase(sIdle, Seq(
                        (invalidate  , sRefill)
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
            .elsewhen(valid)
            {
                state           := Mux(uncached, sMiss, sLookup)
                addr_ok         := 1.U
                req_valid       := valid
                req_uncached    := uncached
                req_op          := op
                req_tag         := tag
                req_set         := index
                req_offset      := offset
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
        is (sMiss){
            state                   := sReplace
            for(i <- 0 until nrLines){
                when(!tagv(i).douta(20)){
                    refillHit           := 1.U
                    refillIDX           := i.U
                }
            }
            for(i  <- 0 until nrLines){
                when(tagv(i).douta(19, 0) === req_tag && tagv(i).douta(20)){
                    refillHit           := 1.U
                    refillIDX           := i.U
                }
            }
            when(!refillHit){
                refillIDX               := LFSR_result(lineWidth-1, 0)
            }
            refillIDX_r             := refillIDX
            req_rline               := refillIDX
        }
        is (sReplace){
            state           := sReplace
            rd_req          := Mux((req_op && req_uncached) && !fill, 0.U,  1.U)
            rd_type         := Mux(req_uncached, "b010".U, "b100".U)
            rd_addr         := Mux(req_uncached, Cat(Seq(req_tag, req_set, req_offset)), Cat(Seq(req_tag, req_set, 0.U(4.W))))
            when(rd_rdy){
                state       := sRefill   
            }
        }   
        is (sRefill){
            state                       := sRefill
            when((!req_uncached & !cacheInst_r) || fill)
            {
                when(ret_valid)
                {
                    wr_cnt                                  := wr_cnt + 1.U
                    data(refillIDX_r)(wr_cnt).dina          := ret_data
                    data(refillIDX_r)(wr_cnt).wea           := 0xF.U
                    when(ret_last)
                    {
                        state                               := sLookup
                        tagv(refillIDX_r).wea               := 1.U
                        tagv(refillIDX_r).dina              := Cat(1.B, req_tag)
                        cacheInst_r                         := 0.U
                        invalidate                          := 0.U
                        indexOnly                           := 0.U
                        writeBack                           := 0.U
                        storeTag                            := 0.U
                        loadTag                             := 0.U
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
            }
            .otherwise{
                state                                       := sIdle
                cache_op_done                               := 1.U
                when(loadTag){
                    tag_output                              := Cat(0.B, tagv(waySel).douta(20, 0))
                }
                when(storeTag){
                    tagv(waySel).dina                            := tag_input(20, 0)
                    tagv(waySel).wea                             := 1.U
                }
                when(invalidate){
                    when(indexOnly){
                        tagv(waySel).dina                        := 0.U
                        tagv(waySel).wea                         := 1.U
                    }.otherwise{
                        tagv(refillIDX_r).dina                   := 0.U
                        tagv(refillIDX_r).wea                    := 1.U
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

}



