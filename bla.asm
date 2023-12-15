_start:
	push hello
	push helloLen
	call print
	sub rsp , 16
	ret
print:
    mov rdi, 0x1
    mov rsi, [rsp + $16]
    mov rdx, [rsp + 8]
    mov rax, 0x1
    syscall
  	ret

