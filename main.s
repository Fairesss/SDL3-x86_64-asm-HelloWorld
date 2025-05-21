	.set	SDL_INIT_VIDEO, 	0x20
	.set	SDL_EVENT_QUIT, 	0x100
	.set	SDL_EVENT_MOUSE_MOTION, 0x200
	.set	SDL_WINDOW_VULKAN,	0x10000000
	
	.macro divm n, d, q, r
	movq	\n, %rax
	movq	\d, %rbx
	xor	%rdx, %rdx
	div	%rbx
	movq	%rax, \q
	movq	%rdx, \r
	.endm

	.macro ftoi src, dst
	cvtss2si	\src, \dst
	.endm
	
	.bss
VkApplicationInfo:
	.skip 48
	
	.data
title:
	.string "Hello, World!"

	
m_x:
	.int 	0
m_y:
	.int	0

	.text
	.global _start

set_mouse:
	pushq	%rbp
	movq	%rsp, %rbp

	subq	$16, %rsp

	leaq	0(%rsp), %rax
	leaq	4(%rsp), %rdx

	movq	%rax, %rsi
	movq	%rdx, %rdi
	
	call 	SDL_GetMouseState

	movss	0(%rsp), %xmm0
	movss	4(%rsp), %xmm1

	ftoi	%xmm0, %r10
	ftoi	%xmm1, %r11

	movq	%r10, m_x
	movq	%r11, m_y


	divm	%r10, $255, %rax, %rdx
	movq 	%rdx, m_x

	divm	%r11, $255, %rax, %rdx
	movq	%rdx, m_y
	
	addq	$16, %rsp
	popq	%rbp
	ret


_start:
	movq	%rsp, %rbp
	subq  	$0x10, %rsp

	movq 	$SDL_INIT_VIDEO, %rdi 
	call 	SDL_Init

	leaq 	title(%rip), %rdi
	movq 	$255, %rsi
	movq 	$255, %rdx
	movq  	$SDL_WINDOW_VULKAN, %rcx
	call 	SDL_CreateWindow

	
	
	movq 	%rax, (%rsp)

	movq 	(%rsp), %rdi
	xor 	%rsi, %rsi
	call 	SDL_CreateRenderer
	movq 	%rax, 8(%rsp)

loop:	
input_loop:	
	leaq 	16(%rsp), %rdi
	call 	SDL_PollEvent
	test 	%rax, %rax
	jz   	render_loop


	
	movl 	16(%rsp), %eax
	cmp  	$SDL_EVENT_QUIT, %eax
	je 	quit

	call set_mouse
	

	jmp input_loop
render_loop:	

	movl 	m_x, %esi
	
	movl  	m_y, %edx
	
	movl  	$0, %ecx

	movq	$255, %r8
	
	movq 	8(%rsp), %rdi

	call 	SDL_SetRenderDrawColor

	movq 	8(%rsp), %rdi
	call 	SDL_RenderClear

	movq 	8(%rsp), %rdi
	call 	SDL_RenderPresent

	jmp 	loop

quit:	
	

	movq 	8(%rsp), %rdi
	call 	SDL_DestroyRenderer

	movq 	(%rsp), %rdi
	call 	SDL_DestroyWindow
 

	call 	SDL_Quit
		
	movl 	$0, %edi
	call 	exit
