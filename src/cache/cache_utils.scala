import chisel3._
import chisel3.util._
 
 /******************** IP FROM VIVADO ********************/ 

class data_ram extends BlackBox {
    val io = IO{new Bundle{
        val addra = Input(UInt(8.W))
        val clka  = Input(Clock())
        val dina  = Input(UInt(32.W))
        val douta = Output(UInt(32.W))
        val wea   = Input(UInt(4.W))
    }}
}

class tagv_ram extends BlackBox {
    val io = IO{new Bundle{
        val addra = Input(UInt(8.W))
        val clka  = Input(Clock())
        val dina  = Input(UInt(21.W))
        val douta = Output(UInt(21.W))
        val wea   = Input(Bool())
    }}
}

object MIPS32CacheOp{
    def cIndexWBInvalid     = BitPat("b000")
    def cIndexLdTag         = BitPat("b001")
    def cIndexStrTag        = BitPat("b010")
    def cInplemDependant    = BitPat("b011")
    def cHitInvalid         = BitPat("b100")
    def cHitWBInvalid       = BitPat("b101")
    def cHitWB              = BitPat("b110")
    def cFetchAndLock       = BitPat("b111")

    val table = Array(
        cIndexWBInvalid        -> List(1.B, 0.B, 0.B, 1.B, 1.B),
        cIndexLdTag            -> List(0.B, 1.B, 0.B, 0.B, 1.B),
        cIndexStrTag           -> List(0.B, 0.B, 1.B, 0.B, 1.B),
        cInplemDependant       -> List(0.B, 0.B, 0.B, 0.B, 0.B),
        cHitInvalid            -> List(1.B, 0.B, 0.B, 0.B, 0.B),
        cHitWBInvalid          -> List(1.B, 0.B, 0.B, 1.B, 0.B),
        cHitWB                 -> List(0.B, 0.B, 0.B, 1.B, 0.B),
        cFetchAndLock          -> List(0.B, 0.B, 0.B, 0.B, 0.B)     //unimplemented
    )
}