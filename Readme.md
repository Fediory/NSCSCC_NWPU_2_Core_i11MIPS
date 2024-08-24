# 2023NSCSCC - 西北工业大学二队参赛作品——Core i11MIPS

CoreMIPSi11 CPU 采用单发射七级流水线架构，其频率达到约 90MHz，IPC24.5，可正常运行系统测试、Pmon和Ucore。CPU可支持 MIPS32 Rev 1 中的 93 条指令，19 个 CP0 寄存器，支持两个软件中断(SW0 - SW1)，六个硬件中断(HW0 - HW5)，一个计时器中断，计时器中断复用 HW5 硬件中断。CPU 对外通过 2 个接口进行通信，分别是 Cache 的指令和数据接口（AXI4 协议）。CPU设计详情请参考doc中的文件。



如果您有问题，欢迎与我们沟通！

Yixu Feng

yixu-nwpu@mail.nwpu.edu.cn

Shijie Chen

csj314159@mail.nwpu.edu.cn

Xiaotian Jiang

timba@mail.nwpu.edu.cn

Xuhui Li

lixuhui123@mail.nwpu.edu.cn
