	.data
title:
	.string "Hello, World!"

	.text
	.global _start

_start:
	movq  %rsp, %rbp
	subq  $160, %rsp

	movl $0x20, %edi
	call SDL_Init

	leaq title(%rip), %rdi
	movq $800, %rsi
	movq $600, %rdx
	xor  %rcx, %rcx
	call SDL_CreateWindow
	
	movq %rax, (%rsp)

	movq (%rsp), %rdi
	xor %rsi, %rsi
	call SDL_CreateRenderer
	movq %rax, 8(%rsp)

	movq $255, 144(%rsp)

loop:

input_loop:	
	leaq 16(%rsp), %rdi
	call SDL_PollEvent
	test %rax, %rax
	jz render_loop
	movl 16(%rsp), %eax
	cmp $0x100, %eax
	je quit
	jne input_loop


render_loop:	

	movq 144(%rsp), %rsi
	subq $10, %rsi
	movq %rsi, 144(%rsp)
	
	movq 144(%rsp), %rsi
	movq 144(%rsp), %rdx
	movq 144(%rsp), %rdx
	
	movq 8(%rsp), %rdi
	call SDL_SetRenderDrawColor

	movq 8(%rsp), %rdi
	call SDL_RenderClear

	movq 8(%rsp), %rdi
	call SDL_RenderPresent

	movq $10, %rdi
	call SDL_Delay

	jmp loop

quit:	
	

	movq 8(%rsp), %rdi
	call SDL_DestroyRenderer

	movq (%rsp), %rdi
	call SDL_DestroyWindow
 

	call SDL_Quit
		
	mov $100, %edi
	call exit
