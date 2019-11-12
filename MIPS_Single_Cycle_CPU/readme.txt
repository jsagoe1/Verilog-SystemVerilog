MIPS Single Cycle CPU
-----------------------

Performs a single instruction in one clock cycle.

Performs the following instructions

Inst.	[31:26]	[25:21]	[20:16]	[15:11]	[10:6]	[5:0]	Meaning
----------------------------------------------------------------------------------------
add	000000	rs	rt	rd	00000	100000	Register add
sub	000000	rs	rt	rd	00000	100010	Register subtract
and	000000	rs	rt	rd	00000	100100	Register AND
or	000000	rs	rt	rd	00000	100101	Register OR
xor	000000	rs	rt	rd	00000	100110	Register XOR
sll	000000	00000	rt	rd	sa	000000	Shift left
srl	000000	00000	rt	rd	sa	000010	Logical shift right
sra	000000	00000	rt	rd	sa	000011	Arithmetic shift right
jr	000000	rs	00000	00000	00000	001000	Register jump
addi	001000	rs	rt	Immediate	Immediate add
andi	001100	rs	rt	Immediate	Immediate AND
ori	001101	rs	rt	Immediate	Immediate OR
xori	001110	rs	rt	Immediate	Immediate XOR
lw	100011	rs	rt	offset	Load memory word
sw	101011	rs	rt	offset	Store memory word
beq	000100	rs	rt	offset	Branch on equal
bne	000101	rs	rt	offset	Branch on not equal
lui	001111	00000	rt	Immediate	Load upper immediate
j	000010	address	Jump
jal	000011	address	Call
