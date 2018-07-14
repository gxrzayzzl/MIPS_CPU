	j 	Main
	j	Interruption
	j	Exception
Main:
	addi	$sp		$zero		0
	addi	$t0		$zero		0x40000000
	sw		$zero	8($t0)
	addi	$t1		$zero		0x88888888
	sw		$t1		0($t0)		#初始化TH
	sw		268435455	4($t0)		#初始化TL
	addi	$t1		$zero		3
	sw		$t1		8($t0)
load_number1:
	lw		$t1		32($t0) 	#将UART状态取出
	andi	$t2		$t1			1000B		 #查看是否处于接收空闲状态
	beq		$t2		$zero		load_number1 #如果没有接收到新信号，接着等待
	lw		$s0		28($t0)		#从外设取出第一个操作数
load_number2:
	lw		$t1		32($t0)
	andi	$t2		$t1			1000B
	beq		$t2		$zero		load_number2
	lw		$s1		28($t0)		#从外设取出第二个操作数
	addi	$t1		$s0			0x3ffffc00
	lw		$s2		0($t1)
	addi	$t1		$s1			0x3ffffc00
	lw		$s3		0($t1)
	add		$a0		$s0			$zero
	add		$a1		$s1			$zero
compare:
	beq		$a0		$a1			exit
	blt		$a1		$a0			minus
	add		$t1		$a0			$zero
	add		$a0		$a1			$zero
	add		$a1		$t0			$zero
minus:
	sub		$a0		$a0			$a1
	j		compare
exit:
	lw		$t1		32($t0) 	#将UART状态取出
	andi	$t2		$t1			100B		 #查看是否处于接收空闲状态
	beq		$t2		$zero		exit
	sw		$a0		24($t0)
display_result:
	sw		$a0		12($t0)
decode1:
	sll		$t2		$s2			25
	srl		$t2		$t2			25
	sll		$t3		$s3			25
	srl		$t3		$t3			14
	addi	$t2		$t2			10000000B
	add		$t2		$t2			$t3
	sw		$t2		20($t0)
	jal		Interruption
decode2:
	sll		$t2		$s2			18
	srl		$t2		$t2			25
	sll		$t3		$s3			18
	srl		$t3		$t3			25
	sll		$t3		$t3			11
	addi	$t2		$t2			100000000B
	add		$t2		$t2			$t3
	sw		$t2		20($t0)
	jal		Interruption
decode3:
	sll		$t2		$s2			11
	srl		$t2		$t2			25
	sll		$t3		$s3			11
	srl		$t3		$t3			25
	sll		$t3		$t3			11
	addi	$t2		$t2			1000000000B
	add		$t2		$t2			$t3
	sw		$t2		20($t0)
	jal		Interruption
decode4:
	addi	$t2		$zero		10000000000B
	sw		$t2		20($t0)
	jal		Interruption
	jal		decode1
Interruption:
	lw		$t1		8($t0)
	adddi	$t1		$zero		1
	sw		$t1		8($t0)
	sll		$zero	$zero		0
	jr		$ra
Exception:
	sll		$zero	$zero		0