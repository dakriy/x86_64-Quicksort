# I hate myself for doing this

# Can modify caller saved registers
# allocate varialbes on stack

# Calling conventions
# https://aaronbloomfield.github.io/pdr/book/x86-64bit-ccc-chapter.pdf

# good examples and stuff
# https://en.wikibooks.org/wiki/X86_Assembly/GAS_Syntax

# printf weirdness
# https://stackoverflow.com/questions/6212665/why-is-eax-zeroed-before-a-call-to-printf

# Jump instructions
# http://www.unixwiz.net/techtips/x86-jumps.html

# SYSTEM V ABI
# https://raw.githubusercontent.com/wiki/hjl-tools/x86-psABI/x86-64-psABI-1.0.pdf

# Register and instruction quickstart
# https://wiki.cdot.senecacollege.ca/wiki/X86_64_Register_and_Instruction_Quick_Start

# Useful guide(s)
# http://flint.cs.yale.edu/cs421/papers/x86-asm/asm.html
# https://www.cs.virginia.edu/~evans/cs216/guides/x86.html

# eax number of vector or floating point registers used

# Call to printf? Or something
#		mov  $message, %edx
#		mov $0, %esi
#		mov $message, %edi
#		mov $0, %eax
#		call printf

# If the suffix is not specified, and there are no memory operands for the instruction, GAS infers the operand size
# from the size of the destination register operand (the final operand).

# Basic call to printf
#mov $message, %rdi
#mov $0, %rax # No floating point args
#call printf

		.global main

		.text
		.extern printf
		.extern atol
		.extern memcpy

main:
		# -------------------------------------------------------------
		# STACK
		# -------------------------------------------------------------
		# All the numbers(0)
		# All the numbers(1)
		# All the numbers(2)
		# All the numbers(...)
		# All the numbers(x)
		# -------------------------------------------------------------
		# REGISTERS I CARE ABOUT
		# r15: This contains the number of inputted integers to sort
		#		r15 is callee saved
		# -------------------------------------------------------------
		# rbp is calleee saved
		push %rbp
		mov %rsp, %rbp					# Save base pointer

		# Get number of elements to sort that were passed into argv
		sub $1, %rdi					# First argument is program name So decrement it by one

		# if number of input arguments is 0, just exit
		cmp $0, %rdi
		je byebye

		mov %rdi,%r15					# Save number of arguments to r15

		# I'M RETARTDED ONLY 2 ARGUMENTS. THE SECOND ONE IS THE STUPID ARRAY THING
		# JUST ALLOCATES SPACE ON STACK AND MEMCPY THE ADDRESSSES
		# RSI has the pointer to the c array taht I wanna copy

		# Get num of bytes to allocaate and copy
		shl $3,%rdi						# shift left 3 times is multiply by 8 which gives us number of bytes
		sub %rdi,%rsp					# Allocate stack space


		# memcpy(dst (rsp), src (rsi), size (rdi))
		mov %rdi,%rdx					# Set size first as we need to overwrite register it uses later for the source
		mov %rsp,%rdi					# Set destination address
		add $8,%rsi						# Add 8 to RSI as the first argument is pointer to the program
		call memcpy

		# Resolve all of the string numbers into integer numbers
		mov %r15,%rcx					# rax is our loop counter.
convertLoop:
		dec %rcx
		# rcx is a word too high, so when we use it we need to pre decrement it
		mov (%rsp, %rcx, 8),%rdi			# Get offset of the current pointer and get it ready to send to atoi

		# Do atoi conversion
		push %rcx
		call atol
		pop %rcx

		mov %rax, (%rsp, %rcx, 8)			# Get the number parsed and overwrite it's address on the stack

		# Check loop status
		jrcxz sort
		jmp convertLoop
sort:

		# -------------------------------------------------------------------------------------------------------------
		# Ok now we actually do the quicksort algorithm
		# -------------------------------------------------------------------------------------------------------------
		# The Hoare partition scheme is called with
		# quicksort(Arr, 0, len(arr) - 1)
		# -------------------------------------------------------------------------------------------------------------
		# Right now
		# Arr is stored in rsp and on
		# len(arr) is stored in r15
		# -------------------------------------------------------------------------------------------------------------
		# So lets set stuff up
		# rsp -> rdi
		# 0 -> rsi
		# r15 - 1 -> rdx
		# Don't care about saving anything else as the only other thing I care about is callee saved (r15)
		mov %rsp,%rdi					# arr
		xor %rsi,%rsi					# zero the second parameter
		mov %r15,%rdx					# len(arr)
		dec %rdx						# len(arr) - 1
		call quicksort


		# Everything should be sorted now. So print it out
		# lld is the specifier I want
		# RSP has arr, and r15 is the length, so just start printing them
		mov %r15,%rcx					# move the total count into count register
printLoop:
		dec %rcx						# decrement loop var
		# prepare printf

		mov $message,%rdi				# set the message to print
		mov (%rsp, %rcx, 8),%rsi		# Setup the number to print
		mov $0, %rax					# No floating point args
		push %rcx						# save rcx cause thats our counter
		call printf
		pop %rcx						# bring back rcx

		jrcxz byebye					# check if we done
		jmp printLoop					# otherwise loop again



byebye: 								# exit(0)
		# deallocate stack space
		mov		%rbp, %rsp
		pop		%rbp
		mov     $60, %rax               # system call 60 is exit
		xor     %rdi, %rdi              # we want return code 0
		syscall                         # invoke operating system to exit

# void quicksort(long * a, long index_lo, long index_hi)
quicksort:
		# int * a -> rdi
		# long index_lo -> rsi
		# long index_hi -> rdx

		# Allocate stack space
		# We need space for p which is going to be uh I guess long works for now so:
		sub $8, %rsp

		# Lets use the Hoare partition scheme as it is more efficient
		# algorithm quicksort(A, lo, hi) is
		# -------------------------------------------------------------------------------------------------------------
		#     if lo < hi then
		# -------------------------------------------------------------------------------------------------------------
		# for example cmp $0, %rax followed by jl branch will branch if %rax < 0
		#             cmp %rdx,%rsi                                     %rsi < %rdx
		#				   hi lo										 lo < hi
		cmp %rdx,%rsi
		jge quicksort_done
		# -------------------------------------------------------------------------------------------------------------
		#         p := partition(A, lo, hi)
		# -------------------------------------------------------------------------------------------------------------
		# To move the array into position we need to place it in rdi, which it already is so we can skip this setep
		# ok now move lo into the rsi register, which is already done
		# Now move hi into the rdx register, which has also already been done so we can just call partition and get
		#		the result
		call partition
		mov %rax,(%rsp)				# Retrieve result of partition call onto the locally allocated variable for it

		# -------------------------------------------------------------------------------------------------------------
		#         quicksort(A, lo, p)
		# -------------------------------------------------------------------------------------------------------------
		push %rdx
		# A and lo can stay the same as they are the same as was passed into this subroutine
		mov 8(%rsp),%rdx			# setup p as the new hi and make the call
		call quicksort
		pop %rdx

		# -------------------------------------------------------------------------------------------------------------
		#         quicksort(A, p + 1, hi)
		# -------------------------------------------------------------------------------------------------------------
		# A and hi can stay the same as it is the same as was passed into this subroutine
		push %rsi					# save rsi as we are going to put p there
		mov 8(%rsp),%rsi			# p
		inc %rsi					# p + 1
		call quicksort
		pop %rsi

quicksort_done:
		# Deallocate local variables
		add $8, %rsp
		ret

# void partition(long * a, long index_lo, long index_hi)
partition:
		# int * a -> rdi
		# long lo -> rsi
		# long hi -> rdx

		# Lets use the Hoare partition scheme as it is more efficient

		# r13 is i
		push %r13
		# r14 is pivot
		push %r14

		# i, j, and pivot will all be longs cause thats easiest
		# j will be in rax as we return it
		# j			= rax
		# i			= r13
		# pivot		= r14

		# algorithm partition(A, lo, hi) is
		# -------------------------------------------------------------------------------------------------------------
		#     pivot := A[lo + (hi - lo) / 2]
		# -------------------------------------------------------------------------------------------------------------
		# First calclate the index. and we'll put it into r12 which is callee saved and we did save it
		# int * a -> rdi
		# long lo -> rsi
		# long hi -> rdx
		mov %rdx,%r14				# hi
		sub %rsi,%r14				# hi - lo
		sar $1,%r14					# (hi - lo) / 2
		add %rsi,%r14				# lo + (hi - lo) / 2
		mov (%rdi, %r14, 8),%r14	# pivot = A[lo + (hi - lo) / 2]

		# -------------------------------------------------------------------------------------------------------------
		#     i := lo - 1
		# -------------------------------------------------------------------------------------------------------------
		mov %rsi,%r13				# i = lo
		dec %r13					# i = lo - 1

		# -------------------------------------------------------------------------------------------------------------
		#     j := hi + 1
		# -------------------------------------------------------------------------------------------------------------
		mov %rdx,%rax				# j = hi
		inc %rax					# j = hi + 1

		# -------------------------------------------------------------------------------------------------------------
		#     loop forever
		# -------------------------------------------------------------------------------------------------------------
		# int * a -> rdi
		# long lo -> rsi
		# long hi -> rdx
		# j			= rax
		# i			= r13
		# pivot		= r14
partition_loop:
		# -------------------------------------------------------------------------------------------------------------
		#         do
		# -------------------------------------------------------------------------------------------------------------
partition_first_do:
		# -------------------------------------------------------------------------------------------------------------
		#             i := i + 1
		# -------------------------------------------------------------------------------------------------------------
		inc %r13
		# -------------------------------------------------------------------------------------------------------------
		#         while A[i] < pivot
		# -------------------------------------------------------------------------------------------------------------
		# for example cmp $0, %rax followed by jl branch will branch if %rax < 0
		#              A      i  * 8
		#                pivot,A[i]										A[i] < pivot
		cmp %r14,(%rdi, %r13, 8)			# rdi->A [%r13->i * 8 (becuase byte index)]
		jl partition_first_do				# A[i] < pivot ?

		# -------------------------------------------------------------------------------------------------------------
		#         do
		# -------------------------------------------------------------------------------------------------------------
		# int * a -> rdi
		# j			= rax
		# i			= r13
		# pivot		= r14
partition_second_do:

		# -------------------------------------------------------------------------------------------------------------
		#             j := j - 1
		# -------------------------------------------------------------------------------------------------------------
		dec %rax

		# -------------------------------------------------------------------------------------------------------------
		#         while A[j] > pivot
		# -------------------------------------------------------------------------------------------------------------
		# for example cmp $0, %rax followed by jl branch will branch if %rax < 0
		# cmp  pivot, A[j]											A[j] op pivot
		cmp %r14,(%rdi, %rax, 8)			# rdi->A [rax->j * 8 (becuase byte index)]
											# Flags are now set such that:
											# A[j] op pivot
		jg partition_first_do				# A[j] > pivot

		# -------------------------------------------------------------------------------------------------------------
		#         if i >= j then
		# -------------------------------------------------------------------------------------------------------------
		cmp %rax,%r13						# i op j
		jl partition_swap					# i < j don't do if
		# -------------------------------------------------------------------------------------------------------------
		#             return j
		# -------------------------------------------------------------------------------------------------------------
		jmp partition_done					# just go to exit as j is already in rax
partition_swap:
		# -------------------------------------------------------------------------------------------------------------
		#         swap A[i] with A[j]
		# -------------------------------------------------------------------------------------------------------------
		# r12 is our tmp register
		# int * a -> rdi
		# j			= rax
		# i			= r13

		push (%rdi, %r13, 8)				# push A[i]
		push (%rdi, %rax, 8)				# push A[j}
		pop (%rdi, %r13, 8)					# pop A[j] into A[i]
		pop (%rdi, %rax, 8)					# pop A[i] into A[j]

		jmp partition_loop			# looping forever
partition_done:
		# bring back registers I used
		pop %r14
		pop %r13
		ret


message:
		.ascii "%lld\n\0"