
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 40 19 10 f0       	push   $0xf0101940
f0100050:	e8 92 09 00 00       	call   f01009e7 <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 e5 06 00 00       	call   f0100760 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 5c 19 10 f0       	push   $0xf010195c
f0100087:	e8 5b 09 00 00       	call   f01009e7 <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 ef 13 00 00       	call   f01014a0 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 8f 04 00 00       	call   f0100545 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 77 19 10 f0       	push   $0xf0101977
f01000c3:	e8 1f 09 00 00       	call   f01009e7 <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f01000c8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f01000cf:	e8 6c ff ff ff       	call   f0100040 <test_backtrace>
f01000d4:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f01000d7:	83 ec 0c             	sub    $0xc,%esp
f01000da:	6a 00                	push   $0x0
f01000dc:	e8 86 07 00 00       	call   f0100867 <monitor>
f01000e1:	83 c4 10             	add    $0x10,%esp
f01000e4:	eb f1                	jmp    f01000d7 <i386_init+0x43>

f01000e6 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000e6:	55                   	push   %ebp
f01000e7:	89 e5                	mov    %esp,%ebp
f01000e9:	56                   	push   %esi
f01000ea:	53                   	push   %ebx
f01000eb:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000ee:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f01000f5:	75 37                	jne    f010012e <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000f7:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f01000fd:	fa                   	cli    
f01000fe:	fc                   	cld    

	va_start(ap, fmt);
f01000ff:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100102:	83 ec 04             	sub    $0x4,%esp
f0100105:	ff 75 0c             	pushl  0xc(%ebp)
f0100108:	ff 75 08             	pushl  0x8(%ebp)
f010010b:	68 92 19 10 f0       	push   $0xf0101992
f0100110:	e8 d2 08 00 00       	call   f01009e7 <cprintf>
	vcprintf(fmt, ap);
f0100115:	83 c4 08             	add    $0x8,%esp
f0100118:	53                   	push   %ebx
f0100119:	56                   	push   %esi
f010011a:	e8 a2 08 00 00       	call   f01009c1 <vcprintf>
	cprintf("\n");
f010011f:	c7 04 24 ce 19 10 f0 	movl   $0xf01019ce,(%esp)
f0100126:	e8 bc 08 00 00       	call   f01009e7 <cprintf>
	va_end(ap);
f010012b:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010012e:	83 ec 0c             	sub    $0xc,%esp
f0100131:	6a 00                	push   $0x0
f0100133:	e8 2f 07 00 00       	call   f0100867 <monitor>
f0100138:	83 c4 10             	add    $0x10,%esp
f010013b:	eb f1                	jmp    f010012e <_panic+0x48>

f010013d <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010013d:	55                   	push   %ebp
f010013e:	89 e5                	mov    %esp,%ebp
f0100140:	53                   	push   %ebx
f0100141:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100144:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100147:	ff 75 0c             	pushl  0xc(%ebp)
f010014a:	ff 75 08             	pushl  0x8(%ebp)
f010014d:	68 aa 19 10 f0       	push   $0xf01019aa
f0100152:	e8 90 08 00 00       	call   f01009e7 <cprintf>
	vcprintf(fmt, ap);
f0100157:	83 c4 08             	add    $0x8,%esp
f010015a:	53                   	push   %ebx
f010015b:	ff 75 10             	pushl  0x10(%ebp)
f010015e:	e8 5e 08 00 00       	call   f01009c1 <vcprintf>
	cprintf("\n");
f0100163:	c7 04 24 ce 19 10 f0 	movl   $0xf01019ce,(%esp)
f010016a:	e8 78 08 00 00       	call   f01009e7 <cprintf>
	va_end(ap);
}
f010016f:	83 c4 10             	add    $0x10,%esp
f0100172:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100175:	c9                   	leave  
f0100176:	c3                   	ret    

f0100177 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100177:	55                   	push   %ebp
f0100178:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010017a:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010017f:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100180:	a8 01                	test   $0x1,%al
f0100182:	74 0b                	je     f010018f <serial_proc_data+0x18>
f0100184:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100189:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010018a:	0f b6 c0             	movzbl %al,%eax
f010018d:	eb 05                	jmp    f0100194 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010018f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100194:	5d                   	pop    %ebp
f0100195:	c3                   	ret    

f0100196 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100196:	55                   	push   %ebp
f0100197:	89 e5                	mov    %esp,%ebp
f0100199:	53                   	push   %ebx
f010019a:	83 ec 04             	sub    $0x4,%esp
f010019d:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010019f:	eb 2b                	jmp    f01001cc <cons_intr+0x36>
		if (c == 0)
f01001a1:	85 c0                	test   %eax,%eax
f01001a3:	74 27                	je     f01001cc <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a5:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001ab:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ae:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001b4:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001ba:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001c0:	75 0a                	jne    f01001cc <cons_intr+0x36>
			cons.wpos = 0;
f01001c2:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f01001c9:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001cc:	ff d3                	call   *%ebx
f01001ce:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d1:	75 ce                	jne    f01001a1 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001d3:	83 c4 04             	add    $0x4,%esp
f01001d6:	5b                   	pop    %ebx
f01001d7:	5d                   	pop    %ebp
f01001d8:	c3                   	ret    

f01001d9 <kbd_proc_data>:
f01001d9:	ba 64 00 00 00       	mov    $0x64,%edx
f01001de:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001df:	a8 01                	test   $0x1,%al
f01001e1:	0f 84 f0 00 00 00    	je     f01002d7 <kbd_proc_data+0xfe>
f01001e7:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ec:	ec                   	in     (%dx),%al
f01001ed:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001ef:	3c e0                	cmp    $0xe0,%al
f01001f1:	75 0d                	jne    f0100200 <kbd_proc_data+0x27>
		// E0 escape character
		shift |= E0ESC;
f01001f3:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f01001fa:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01001ff:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100200:	55                   	push   %ebp
f0100201:	89 e5                	mov    %esp,%ebp
f0100203:	53                   	push   %ebx
f0100204:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100207:	84 c0                	test   %al,%al
f0100209:	79 36                	jns    f0100241 <kbd_proc_data+0x68>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010020b:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100211:	89 cb                	mov    %ecx,%ebx
f0100213:	83 e3 40             	and    $0x40,%ebx
f0100216:	83 e0 7f             	and    $0x7f,%eax
f0100219:	85 db                	test   %ebx,%ebx
f010021b:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f010021e:	0f b6 d2             	movzbl %dl,%edx
f0100221:	0f b6 82 20 1b 10 f0 	movzbl -0xfefe4e0(%edx),%eax
f0100228:	83 c8 40             	or     $0x40,%eax
f010022b:	0f b6 c0             	movzbl %al,%eax
f010022e:	f7 d0                	not    %eax
f0100230:	21 c8                	and    %ecx,%eax
f0100232:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f0100237:	b8 00 00 00 00       	mov    $0x0,%eax
f010023c:	e9 9e 00 00 00       	jmp    f01002df <kbd_proc_data+0x106>
	} else if (shift & E0ESC) {
f0100241:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100247:	f6 c1 40             	test   $0x40,%cl
f010024a:	74 0e                	je     f010025a <kbd_proc_data+0x81>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010024c:	83 c8 80             	or     $0xffffff80,%eax
f010024f:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100251:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100254:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f010025a:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010025d:	0f b6 82 20 1b 10 f0 	movzbl -0xfefe4e0(%edx),%eax
f0100264:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f010026a:	0f b6 8a 20 1a 10 f0 	movzbl -0xfefe5e0(%edx),%ecx
f0100271:	31 c8                	xor    %ecx,%eax
f0100273:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100278:	89 c1                	mov    %eax,%ecx
f010027a:	83 e1 03             	and    $0x3,%ecx
f010027d:	8b 0c 8d 00 1a 10 f0 	mov    -0xfefe600(,%ecx,4),%ecx
f0100284:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100288:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010028b:	a8 08                	test   $0x8,%al
f010028d:	74 1b                	je     f01002aa <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f010028f:	89 da                	mov    %ebx,%edx
f0100291:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100294:	83 f9 19             	cmp    $0x19,%ecx
f0100297:	77 05                	ja     f010029e <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f0100299:	83 eb 20             	sub    $0x20,%ebx
f010029c:	eb 0c                	jmp    f01002aa <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010029e:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002a1:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002a4:	83 fa 19             	cmp    $0x19,%edx
f01002a7:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002aa:	f7 d0                	not    %eax
f01002ac:	a8 06                	test   $0x6,%al
f01002ae:	75 2d                	jne    f01002dd <kbd_proc_data+0x104>
f01002b0:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002b6:	75 25                	jne    f01002dd <kbd_proc_data+0x104>
		cprintf("Rebooting!\n");
f01002b8:	83 ec 0c             	sub    $0xc,%esp
f01002bb:	68 c4 19 10 f0       	push   $0xf01019c4
f01002c0:	e8 22 07 00 00       	call   f01009e7 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c5:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ca:	b8 03 00 00 00       	mov    $0x3,%eax
f01002cf:	ee                   	out    %al,(%dx)
f01002d0:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d3:	89 d8                	mov    %ebx,%eax
f01002d5:	eb 08                	jmp    f01002df <kbd_proc_data+0x106>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002dc:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002dd:	89 d8                	mov    %ebx,%eax
}
f01002df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002e2:	c9                   	leave  
f01002e3:	c3                   	ret    

f01002e4 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002e4:	55                   	push   %ebp
f01002e5:	89 e5                	mov    %esp,%ebp
f01002e7:	57                   	push   %edi
f01002e8:	56                   	push   %esi
f01002e9:	53                   	push   %ebx
f01002ea:	83 ec 1c             	sub    $0x1c,%esp
f01002ed:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ef:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f4:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002f9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fe:	eb 09                	jmp    f0100309 <cons_putc+0x25>
f0100300:	89 ca                	mov    %ecx,%edx
f0100302:	ec                   	in     (%dx),%al
f0100303:	ec                   	in     (%dx),%al
f0100304:	ec                   	in     (%dx),%al
f0100305:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100306:	83 c3 01             	add    $0x1,%ebx
f0100309:	89 f2                	mov    %esi,%edx
f010030b:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010030c:	a8 20                	test   $0x20,%al
f010030e:	75 08                	jne    f0100318 <cons_putc+0x34>
f0100310:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100316:	7e e8                	jle    f0100300 <cons_putc+0x1c>
f0100318:	89 f8                	mov    %edi,%eax
f010031a:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010031d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100322:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100323:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100328:	be 79 03 00 00       	mov    $0x379,%esi
f010032d:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100332:	eb 09                	jmp    f010033d <cons_putc+0x59>
f0100334:	89 ca                	mov    %ecx,%edx
f0100336:	ec                   	in     (%dx),%al
f0100337:	ec                   	in     (%dx),%al
f0100338:	ec                   	in     (%dx),%al
f0100339:	ec                   	in     (%dx),%al
f010033a:	83 c3 01             	add    $0x1,%ebx
f010033d:	89 f2                	mov    %esi,%edx
f010033f:	ec                   	in     (%dx),%al
f0100340:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100346:	7f 04                	jg     f010034c <cons_putc+0x68>
f0100348:	84 c0                	test   %al,%al
f010034a:	79 e8                	jns    f0100334 <cons_putc+0x50>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034c:	ba 78 03 00 00       	mov    $0x378,%edx
f0100351:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100355:	ee                   	out    %al,(%dx)
f0100356:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010035b:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100360:	ee                   	out    %al,(%dx)
f0100361:	b8 08 00 00 00       	mov    $0x8,%eax
f0100366:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100367:	89 fa                	mov    %edi,%edx
f0100369:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f010036f:	89 f8                	mov    %edi,%eax
f0100371:	80 cc 07             	or     $0x7,%ah
f0100374:	85 d2                	test   %edx,%edx
f0100376:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100379:	89 f8                	mov    %edi,%eax
f010037b:	0f b6 c0             	movzbl %al,%eax
f010037e:	83 f8 09             	cmp    $0x9,%eax
f0100381:	74 74                	je     f01003f7 <cons_putc+0x113>
f0100383:	83 f8 09             	cmp    $0x9,%eax
f0100386:	7f 0a                	jg     f0100392 <cons_putc+0xae>
f0100388:	83 f8 08             	cmp    $0x8,%eax
f010038b:	74 14                	je     f01003a1 <cons_putc+0xbd>
f010038d:	e9 99 00 00 00       	jmp    f010042b <cons_putc+0x147>
f0100392:	83 f8 0a             	cmp    $0xa,%eax
f0100395:	74 3a                	je     f01003d1 <cons_putc+0xed>
f0100397:	83 f8 0d             	cmp    $0xd,%eax
f010039a:	74 3d                	je     f01003d9 <cons_putc+0xf5>
f010039c:	e9 8a 00 00 00       	jmp    f010042b <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003a1:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003a8:	66 85 c0             	test   %ax,%ax
f01003ab:	0f 84 e6 00 00 00    	je     f0100497 <cons_putc+0x1b3>
			crt_pos--;
f01003b1:	83 e8 01             	sub    $0x1,%eax
f01003b4:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003ba:	0f b7 c0             	movzwl %ax,%eax
f01003bd:	66 81 e7 00 ff       	and    $0xff00,%di
f01003c2:	83 cf 20             	or     $0x20,%edi
f01003c5:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01003cb:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003cf:	eb 78                	jmp    f0100449 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003d1:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f01003d8:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003d9:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003e0:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e6:	c1 e8 16             	shr    $0x16,%eax
f01003e9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003ec:	c1 e0 04             	shl    $0x4,%eax
f01003ef:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f01003f5:	eb 52                	jmp    f0100449 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003f7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003fc:	e8 e3 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f0100401:	b8 20 00 00 00       	mov    $0x20,%eax
f0100406:	e8 d9 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f010040b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100410:	e8 cf fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f0100415:	b8 20 00 00 00       	mov    $0x20,%eax
f010041a:	e8 c5 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f010041f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100424:	e8 bb fe ff ff       	call   f01002e4 <cons_putc>
f0100429:	eb 1e                	jmp    f0100449 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010042b:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f0100432:	8d 50 01             	lea    0x1(%eax),%edx
f0100435:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f010043c:	0f b7 c0             	movzwl %ax,%eax
f010043f:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100445:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100449:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f0100450:	cf 07 
f0100452:	76 43                	jbe    f0100497 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100454:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f0100459:	83 ec 04             	sub    $0x4,%esp
f010045c:	68 00 0f 00 00       	push   $0xf00
f0100461:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100467:	52                   	push   %edx
f0100468:	50                   	push   %eax
f0100469:	e8 7f 10 00 00       	call   f01014ed <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010046e:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100474:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010047a:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100480:	83 c4 10             	add    $0x10,%esp
f0100483:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100488:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010048b:	39 d0                	cmp    %edx,%eax
f010048d:	75 f4                	jne    f0100483 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010048f:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f0100496:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100497:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f010049d:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004a2:	89 ca                	mov    %ecx,%edx
f01004a4:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a5:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004ac:	8d 71 01             	lea    0x1(%ecx),%esi
f01004af:	89 d8                	mov    %ebx,%eax
f01004b1:	66 c1 e8 08          	shr    $0x8,%ax
f01004b5:	89 f2                	mov    %esi,%edx
f01004b7:	ee                   	out    %al,(%dx)
f01004b8:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004bd:	89 ca                	mov    %ecx,%edx
f01004bf:	ee                   	out    %al,(%dx)
f01004c0:	89 d8                	mov    %ebx,%eax
f01004c2:	89 f2                	mov    %esi,%edx
f01004c4:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004c8:	5b                   	pop    %ebx
f01004c9:	5e                   	pop    %esi
f01004ca:	5f                   	pop    %edi
f01004cb:	5d                   	pop    %ebp
f01004cc:	c3                   	ret    

f01004cd <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004cd:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f01004d4:	74 11                	je     f01004e7 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004d6:	55                   	push   %ebp
f01004d7:	89 e5                	mov    %esp,%ebp
f01004d9:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004dc:	b8 77 01 10 f0       	mov    $0xf0100177,%eax
f01004e1:	e8 b0 fc ff ff       	call   f0100196 <cons_intr>
}
f01004e6:	c9                   	leave  
f01004e7:	f3 c3                	repz ret 

f01004e9 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004e9:	55                   	push   %ebp
f01004ea:	89 e5                	mov    %esp,%ebp
f01004ec:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004ef:	b8 d9 01 10 f0       	mov    $0xf01001d9,%eax
f01004f4:	e8 9d fc ff ff       	call   f0100196 <cons_intr>
}
f01004f9:	c9                   	leave  
f01004fa:	c3                   	ret    

f01004fb <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004fb:	55                   	push   %ebp
f01004fc:	89 e5                	mov    %esp,%ebp
f01004fe:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100501:	e8 c7 ff ff ff       	call   f01004cd <serial_intr>
	kbd_intr();
f0100506:	e8 de ff ff ff       	call   f01004e9 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010050b:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f0100510:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100516:	74 26                	je     f010053e <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100518:	8d 50 01             	lea    0x1(%eax),%edx
f010051b:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f0100521:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100528:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010052a:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100530:	75 11                	jne    f0100543 <cons_getc+0x48>
			cons.rpos = 0;
f0100532:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100539:	00 00 00 
f010053c:	eb 05                	jmp    f0100543 <cons_getc+0x48>
		return c;
	}
	return 0;
f010053e:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	57                   	push   %edi
f0100549:	56                   	push   %esi
f010054a:	53                   	push   %ebx
f010054b:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010054e:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100555:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010055c:	5a a5 
	if (*cp != 0xA55A) {
f010055e:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100565:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100569:	74 11                	je     f010057c <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010056b:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f0100572:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100575:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010057a:	eb 16                	jmp    f0100592 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010057c:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100583:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f010058a:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010058d:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100592:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f0100598:	b8 0e 00 00 00       	mov    $0xe,%eax
f010059d:	89 fa                	mov    %edi,%edx
f010059f:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005a0:	8d 5f 01             	lea    0x1(%edi),%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005a3:	89 da                	mov    %ebx,%edx
f01005a5:	ec                   	in     (%dx),%al
f01005a6:	0f b6 c8             	movzbl %al,%ecx
f01005a9:	c1 e1 08             	shl    $0x8,%ecx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005ac:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b1:	89 fa                	mov    %edi,%edx
f01005b3:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b4:	89 da                	mov    %ebx,%edx
f01005b6:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005b7:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f01005bd:	0f b6 c0             	movzbl %al,%eax
f01005c0:	09 c8                	or     %ecx,%eax
f01005c2:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005c8:	be fa 03 00 00       	mov    $0x3fa,%esi
f01005cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d2:	89 f2                	mov    %esi,%edx
f01005d4:	ee                   	out    %al,(%dx)
f01005d5:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005da:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005df:	ee                   	out    %al,(%dx)
f01005e0:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005e5:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005ea:	89 da                	mov    %ebx,%edx
f01005ec:	ee                   	out    %al,(%dx)
f01005ed:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005f2:	b8 00 00 00 00       	mov    $0x0,%eax
f01005f7:	ee                   	out    %al,(%dx)
f01005f8:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005fd:	b8 03 00 00 00       	mov    $0x3,%eax
f0100602:	ee                   	out    %al,(%dx)
f0100603:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100608:	b8 00 00 00 00       	mov    $0x0,%eax
f010060d:	ee                   	out    %al,(%dx)
f010060e:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100613:	b8 01 00 00 00       	mov    $0x1,%eax
f0100618:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100619:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010061e:	ec                   	in     (%dx),%al
f010061f:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100621:	3c ff                	cmp    $0xff,%al
f0100623:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f010062a:	89 f2                	mov    %esi,%edx
f010062c:	ec                   	in     (%dx),%al
f010062d:	89 da                	mov    %ebx,%edx
f010062f:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100630:	80 f9 ff             	cmp    $0xff,%cl
f0100633:	75 10                	jne    f0100645 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100635:	83 ec 0c             	sub    $0xc,%esp
f0100638:	68 d0 19 10 f0       	push   $0xf01019d0
f010063d:	e8 a5 03 00 00       	call   f01009e7 <cprintf>
f0100642:	83 c4 10             	add    $0x10,%esp
}
f0100645:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100648:	5b                   	pop    %ebx
f0100649:	5e                   	pop    %esi
f010064a:	5f                   	pop    %edi
f010064b:	5d                   	pop    %ebp
f010064c:	c3                   	ret    

f010064d <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010064d:	55                   	push   %ebp
f010064e:	89 e5                	mov    %esp,%ebp
f0100650:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100653:	8b 45 08             	mov    0x8(%ebp),%eax
f0100656:	e8 89 fc ff ff       	call   f01002e4 <cons_putc>
}
f010065b:	c9                   	leave  
f010065c:	c3                   	ret    

f010065d <getchar>:

int
getchar(void)
{
f010065d:	55                   	push   %ebp
f010065e:	89 e5                	mov    %esp,%ebp
f0100660:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100663:	e8 93 fe ff ff       	call   f01004fb <cons_getc>
f0100668:	85 c0                	test   %eax,%eax
f010066a:	74 f7                	je     f0100663 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010066c:	c9                   	leave  
f010066d:	c3                   	ret    

f010066e <iscons>:

int
iscons(int fdnum)
{
f010066e:	55                   	push   %ebp
f010066f:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100671:	b8 01 00 00 00       	mov    $0x1,%eax
f0100676:	5d                   	pop    %ebp
f0100677:	c3                   	ret    

f0100678 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100678:	55                   	push   %ebp
f0100679:	89 e5                	mov    %esp,%ebp
f010067b:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010067e:	68 20 1c 10 f0       	push   $0xf0101c20
f0100683:	68 3e 1c 10 f0       	push   $0xf0101c3e
f0100688:	68 43 1c 10 f0       	push   $0xf0101c43
f010068d:	e8 55 03 00 00       	call   f01009e7 <cprintf>
f0100692:	83 c4 0c             	add    $0xc,%esp
f0100695:	68 e8 1c 10 f0       	push   $0xf0101ce8
f010069a:	68 4c 1c 10 f0       	push   $0xf0101c4c
f010069f:	68 43 1c 10 f0       	push   $0xf0101c43
f01006a4:	e8 3e 03 00 00       	call   f01009e7 <cprintf>
	return 0;
}
f01006a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01006ae:	c9                   	leave  
f01006af:	c3                   	ret    

f01006b0 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006b0:	55                   	push   %ebp
f01006b1:	89 e5                	mov    %esp,%ebp
f01006b3:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006b6:	68 55 1c 10 f0       	push   $0xf0101c55
f01006bb:	e8 27 03 00 00       	call   f01009e7 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01006c0:	83 c4 08             	add    $0x8,%esp
f01006c3:	68 0c 00 10 00       	push   $0x10000c
f01006c8:	68 10 1d 10 f0       	push   $0xf0101d10
f01006cd:	e8 15 03 00 00       	call   f01009e7 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01006d2:	83 c4 0c             	add    $0xc,%esp
f01006d5:	68 0c 00 10 00       	push   $0x10000c
f01006da:	68 0c 00 10 f0       	push   $0xf010000c
f01006df:	68 38 1d 10 f0       	push   $0xf0101d38
f01006e4:	e8 fe 02 00 00       	call   f01009e7 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006e9:	83 c4 0c             	add    $0xc,%esp
f01006ec:	68 31 19 10 00       	push   $0x101931
f01006f1:	68 31 19 10 f0       	push   $0xf0101931
f01006f6:	68 5c 1d 10 f0       	push   $0xf0101d5c
f01006fb:	e8 e7 02 00 00       	call   f01009e7 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100700:	83 c4 0c             	add    $0xc,%esp
f0100703:	68 00 23 11 00       	push   $0x112300
f0100708:	68 00 23 11 f0       	push   $0xf0112300
f010070d:	68 80 1d 10 f0       	push   $0xf0101d80
f0100712:	e8 d0 02 00 00       	call   f01009e7 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100717:	83 c4 0c             	add    $0xc,%esp
f010071a:	68 44 29 11 00       	push   $0x112944
f010071f:	68 44 29 11 f0       	push   $0xf0112944
f0100724:	68 a4 1d 10 f0       	push   $0xf0101da4
f0100729:	e8 b9 02 00 00       	call   f01009e7 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010072e:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100733:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100738:	83 c4 08             	add    $0x8,%esp
f010073b:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100740:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100746:	85 c0                	test   %eax,%eax
f0100748:	0f 48 c2             	cmovs  %edx,%eax
f010074b:	c1 f8 0a             	sar    $0xa,%eax
f010074e:	50                   	push   %eax
f010074f:	68 c8 1d 10 f0       	push   $0xf0101dc8
f0100754:	e8 8e 02 00 00       	call   f01009e7 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100759:	b8 00 00 00 00       	mov    $0x0,%eax
f010075e:	c9                   	leave  
f010075f:	c3                   	ret    

f0100760 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100760:	55                   	push   %ebp
f0100761:	89 e5                	mov    %esp,%ebp
f0100763:	57                   	push   %edi
f0100764:	56                   	push   %esi
f0100765:	53                   	push   %ebx
f0100766:	83 ec 48             	sub    $0x48,%esp
	// Your code here.
	cprintf("Stack backtrace:\n");
f0100769:	68 6e 1c 10 f0       	push   $0xf0101c6e
f010076e:	e8 74 02 00 00       	call   f01009e7 <cprintf>

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100773:	89 ee                	mov    %ebp,%esi
	uint32_t *cur_ebp = (uint32_t *) read_ebp();
	while (cur_ebp) {		
f0100775:	83 c4 10             	add    $0x10,%esp
f0100778:	e9 d5 00 00 00       	jmp    f0100852 <mon_backtrace+0xf2>
		cprintf("ebp %x  ", cur_ebp);
f010077d:	83 ec 08             	sub    $0x8,%esp
f0100780:	56                   	push   %esi
f0100781:	68 80 1c 10 f0       	push   $0xf0101c80
f0100786:	e8 5c 02 00 00       	call   f01009e7 <cprintf>
		cprintf("eip %x  ", cur_ebp[1]);
f010078b:	83 c4 08             	add    $0x8,%esp
f010078e:	ff 76 04             	pushl  0x4(%esi)
f0100791:	68 89 1c 10 f0       	push   $0xf0101c89
f0100796:	e8 4c 02 00 00       	call   f01009e7 <cprintf>
		int i = 0;
		cprintf("args");
f010079b:	c7 04 24 92 1c 10 f0 	movl   $0xf0101c92,(%esp)
f01007a2:	e8 40 02 00 00       	call   f01009e7 <cprintf>
f01007a7:	8d 5e 08             	lea    0x8(%esi),%ebx
f01007aa:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01007ad:	83 c4 10             	add    $0x10,%esp
		for (; i < 5; i++)
			cprintf(" %08x", cur_ebp[2+i]);
f01007b0:	83 ec 08             	sub    $0x8,%esp
f01007b3:	ff 33                	pushl  (%ebx)
f01007b5:	68 97 1c 10 f0       	push   $0xf0101c97
f01007ba:	e8 28 02 00 00       	call   f01009e7 <cprintf>
f01007bf:	83 c3 04             	add    $0x4,%ebx
	while (cur_ebp) {		
		cprintf("ebp %x  ", cur_ebp);
		cprintf("eip %x  ", cur_ebp[1]);
		int i = 0;
		cprintf("args");
		for (; i < 5; i++)
f01007c2:	83 c4 10             	add    $0x10,%esp
f01007c5:	39 fb                	cmp    %edi,%ebx
f01007c7:	75 e7                	jne    f01007b0 <mon_backtrace+0x50>
			cprintf(" %08x", cur_ebp[2+i]);
		cprintf("\n");
f01007c9:	83 ec 0c             	sub    $0xc,%esp
f01007cc:	68 ce 19 10 f0       	push   $0xf01019ce
f01007d1:	e8 11 02 00 00       	call   f01009e7 <cprintf>
		struct Eipdebuginfo info;
		if (debuginfo_eip(cur_ebp[1], &info) == 0) {
f01007d6:	83 c4 08             	add    $0x8,%esp
f01007d9:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01007dc:	50                   	push   %eax
f01007dd:	ff 76 04             	pushl  0x4(%esi)
f01007e0:	e8 0c 03 00 00       	call   f0100af1 <debuginfo_eip>
f01007e5:	83 c4 10             	add    $0x10,%esp
f01007e8:	85 c0                	test   %eax,%eax
f01007ea:	75 64                	jne    f0100850 <mon_backtrace+0xf0>
f01007ec:	89 e3                	mov    %esp,%ebx
			char temp[info.eip_fn_namelen+1];
f01007ee:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f01007f1:	8d 41 10             	lea    0x10(%ecx),%eax
f01007f4:	bf 10 00 00 00       	mov    $0x10,%edi
f01007f9:	ba 00 00 00 00       	mov    $0x0,%edx
f01007fe:	f7 f7                	div    %edi
f0100800:	c1 e0 04             	shl    $0x4,%eax
f0100803:	29 c4                	sub    %eax,%esp
f0100805:	89 e2                	mov    %esp,%edx
			i = 0;
			for (; i < info.eip_fn_namelen; i++)
				temp[i] = info.eip_fn_name[i];
f0100807:	8b 7d d8             	mov    -0x28(%ebp),%edi
			cprintf(" %08x", cur_ebp[2+i]);
		cprintf("\n");
		struct Eipdebuginfo info;
		if (debuginfo_eip(cur_ebp[1], &info) == 0) {
			char temp[info.eip_fn_namelen+1];
			i = 0;
f010080a:	b8 00 00 00 00       	mov    $0x0,%eax
f010080f:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
			for (; i < info.eip_fn_namelen; i++)
f0100812:	eb 0a                	jmp    f010081e <mon_backtrace+0xbe>
				temp[i] = info.eip_fn_name[i];
f0100814:	0f b6 1c 07          	movzbl (%edi,%eax,1),%ebx
f0100818:	88 1c 02             	mov    %bl,(%edx,%eax,1)
		cprintf("\n");
		struct Eipdebuginfo info;
		if (debuginfo_eip(cur_ebp[1], &info) == 0) {
			char temp[info.eip_fn_namelen+1];
			i = 0;
			for (; i < info.eip_fn_namelen; i++)
f010081b:	83 c0 01             	add    $0x1,%eax
f010081e:	39 c8                	cmp    %ecx,%eax
f0100820:	7c f2                	jl     f0100814 <mon_backtrace+0xb4>
f0100822:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
				temp[i] = info.eip_fn_name[i];
			temp[i] = '\0';
f0100825:	85 c9                	test   %ecx,%ecx
f0100827:	b8 00 00 00 00       	mov    $0x0,%eax
f010082c:	0f 48 c8             	cmovs  %eax,%ecx
f010082f:	c6 04 0a 00          	movb   $0x0,(%edx,%ecx,1)
			cprintf(" %s:%d: %s+%x\n", info.eip_file, info.eip_line,
f0100833:	83 ec 0c             	sub    $0xc,%esp
f0100836:	8b 46 04             	mov    0x4(%esi),%eax
f0100839:	2b 45 e0             	sub    -0x20(%ebp),%eax
f010083c:	50                   	push   %eax
f010083d:	52                   	push   %edx
f010083e:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100841:	ff 75 d0             	pushl  -0x30(%ebp)
f0100844:	68 9d 1c 10 f0       	push   $0xf0101c9d
f0100849:	e8 99 01 00 00       	call   f01009e7 <cprintf>
f010084e:	89 dc                	mov    %ebx,%esp
				temp, cur_ebp[1] - info.eip_fn_addr);
		}
		cur_ebp = (uint32_t *) cur_ebp[0];
f0100850:	8b 36                	mov    (%esi),%esi
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	// Your code here.
	cprintf("Stack backtrace:\n");
	uint32_t *cur_ebp = (uint32_t *) read_ebp();
	while (cur_ebp) {		
f0100852:	85 f6                	test   %esi,%esi
f0100854:	0f 85 23 ff ff ff    	jne    f010077d <mon_backtrace+0x1d>
				temp, cur_ebp[1] - info.eip_fn_addr);
		}
		cur_ebp = (uint32_t *) cur_ebp[0];
	}
	return 0;
}
f010085a:	b8 00 00 00 00       	mov    $0x0,%eax
f010085f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100862:	5b                   	pop    %ebx
f0100863:	5e                   	pop    %esi
f0100864:	5f                   	pop    %edi
f0100865:	5d                   	pop    %ebp
f0100866:	c3                   	ret    

f0100867 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100867:	55                   	push   %ebp
f0100868:	89 e5                	mov    %esp,%ebp
f010086a:	57                   	push   %edi
f010086b:	56                   	push   %esi
f010086c:	53                   	push   %ebx
f010086d:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100870:	68 f4 1d 10 f0       	push   $0xf0101df4
f0100875:	e8 6d 01 00 00       	call   f01009e7 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010087a:	c7 04 24 18 1e 10 f0 	movl   $0xf0101e18,(%esp)
f0100881:	e8 61 01 00 00       	call   f01009e7 <cprintf>
f0100886:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100889:	83 ec 0c             	sub    $0xc,%esp
f010088c:	68 ac 1c 10 f0       	push   $0xf0101cac
f0100891:	e8 b3 09 00 00       	call   f0101249 <readline>
f0100896:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100898:	83 c4 10             	add    $0x10,%esp
f010089b:	85 c0                	test   %eax,%eax
f010089d:	74 ea                	je     f0100889 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010089f:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008a6:	be 00 00 00 00       	mov    $0x0,%esi
f01008ab:	eb 0a                	jmp    f01008b7 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008ad:	c6 03 00             	movb   $0x0,(%ebx)
f01008b0:	89 f7                	mov    %esi,%edi
f01008b2:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01008b5:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008b7:	0f b6 03             	movzbl (%ebx),%eax
f01008ba:	84 c0                	test   %al,%al
f01008bc:	74 63                	je     f0100921 <monitor+0xba>
f01008be:	83 ec 08             	sub    $0x8,%esp
f01008c1:	0f be c0             	movsbl %al,%eax
f01008c4:	50                   	push   %eax
f01008c5:	68 b0 1c 10 f0       	push   $0xf0101cb0
f01008ca:	e8 94 0b 00 00       	call   f0101463 <strchr>
f01008cf:	83 c4 10             	add    $0x10,%esp
f01008d2:	85 c0                	test   %eax,%eax
f01008d4:	75 d7                	jne    f01008ad <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01008d6:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008d9:	74 46                	je     f0100921 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008db:	83 fe 0f             	cmp    $0xf,%esi
f01008de:	75 14                	jne    f01008f4 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008e0:	83 ec 08             	sub    $0x8,%esp
f01008e3:	6a 10                	push   $0x10
f01008e5:	68 b5 1c 10 f0       	push   $0xf0101cb5
f01008ea:	e8 f8 00 00 00       	call   f01009e7 <cprintf>
f01008ef:	83 c4 10             	add    $0x10,%esp
f01008f2:	eb 95                	jmp    f0100889 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008f4:	8d 7e 01             	lea    0x1(%esi),%edi
f01008f7:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008fb:	eb 03                	jmp    f0100900 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008fd:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100900:	0f b6 03             	movzbl (%ebx),%eax
f0100903:	84 c0                	test   %al,%al
f0100905:	74 ae                	je     f01008b5 <monitor+0x4e>
f0100907:	83 ec 08             	sub    $0x8,%esp
f010090a:	0f be c0             	movsbl %al,%eax
f010090d:	50                   	push   %eax
f010090e:	68 b0 1c 10 f0       	push   $0xf0101cb0
f0100913:	e8 4b 0b 00 00       	call   f0101463 <strchr>
f0100918:	83 c4 10             	add    $0x10,%esp
f010091b:	85 c0                	test   %eax,%eax
f010091d:	74 de                	je     f01008fd <monitor+0x96>
f010091f:	eb 94                	jmp    f01008b5 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100921:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100928:	00 
	// Lookup and invoke the command
	if (argc == 0)
f0100929:	85 f6                	test   %esi,%esi
f010092b:	0f 84 58 ff ff ff    	je     f0100889 <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100931:	83 ec 08             	sub    $0x8,%esp
f0100934:	68 3e 1c 10 f0       	push   $0xf0101c3e
f0100939:	ff 75 a8             	pushl  -0x58(%ebp)
f010093c:	e8 c4 0a 00 00       	call   f0101405 <strcmp>
f0100941:	83 c4 10             	add    $0x10,%esp
f0100944:	85 c0                	test   %eax,%eax
f0100946:	74 1e                	je     f0100966 <monitor+0xff>
f0100948:	83 ec 08             	sub    $0x8,%esp
f010094b:	68 4c 1c 10 f0       	push   $0xf0101c4c
f0100950:	ff 75 a8             	pushl  -0x58(%ebp)
f0100953:	e8 ad 0a 00 00       	call   f0101405 <strcmp>
f0100958:	83 c4 10             	add    $0x10,%esp
f010095b:	85 c0                	test   %eax,%eax
f010095d:	75 2f                	jne    f010098e <monitor+0x127>
	}
	argv[argc] = 0;
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f010095f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100964:	eb 05                	jmp    f010096b <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100966:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f010096b:	83 ec 04             	sub    $0x4,%esp
f010096e:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100971:	01 d0                	add    %edx,%eax
f0100973:	ff 75 08             	pushl  0x8(%ebp)
f0100976:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100979:	51                   	push   %ecx
f010097a:	56                   	push   %esi
f010097b:	ff 14 85 48 1e 10 f0 	call   *-0xfefe1b8(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100982:	83 c4 10             	add    $0x10,%esp
f0100985:	85 c0                	test   %eax,%eax
f0100987:	78 1d                	js     f01009a6 <monitor+0x13f>
f0100989:	e9 fb fe ff ff       	jmp    f0100889 <monitor+0x22>
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010098e:	83 ec 08             	sub    $0x8,%esp
f0100991:	ff 75 a8             	pushl  -0x58(%ebp)
f0100994:	68 d2 1c 10 f0       	push   $0xf0101cd2
f0100999:	e8 49 00 00 00       	call   f01009e7 <cprintf>
f010099e:	83 c4 10             	add    $0x10,%esp
f01009a1:	e9 e3 fe ff ff       	jmp    f0100889 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009a9:	5b                   	pop    %ebx
f01009aa:	5e                   	pop    %esi
f01009ab:	5f                   	pop    %edi
f01009ac:	5d                   	pop    %ebp
f01009ad:	c3                   	ret    

f01009ae <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f01009ae:	55                   	push   %ebp
f01009af:	89 e5                	mov    %esp,%ebp
f01009b1:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f01009b4:	ff 75 08             	pushl  0x8(%ebp)
f01009b7:	e8 91 fc ff ff       	call   f010064d <cputchar>
	*cnt++;
}
f01009bc:	83 c4 10             	add    $0x10,%esp
f01009bf:	c9                   	leave  
f01009c0:	c3                   	ret    

f01009c1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01009c1:	55                   	push   %ebp
f01009c2:	89 e5                	mov    %esp,%ebp
f01009c4:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01009c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01009ce:	ff 75 0c             	pushl  0xc(%ebp)
f01009d1:	ff 75 08             	pushl  0x8(%ebp)
f01009d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009d7:	50                   	push   %eax
f01009d8:	68 ae 09 10 f0       	push   $0xf01009ae
f01009dd:	e8 52 04 00 00       	call   f0100e34 <vprintfmt>
	return cnt;
}
f01009e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009e5:	c9                   	leave  
f01009e6:	c3                   	ret    

f01009e7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009e7:	55                   	push   %ebp
f01009e8:	89 e5                	mov    %esp,%ebp
f01009ea:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009ed:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009f0:	50                   	push   %eax
f01009f1:	ff 75 08             	pushl  0x8(%ebp)
f01009f4:	e8 c8 ff ff ff       	call   f01009c1 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009f9:	c9                   	leave  
f01009fa:	c3                   	ret    

f01009fb <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009fb:	55                   	push   %ebp
f01009fc:	89 e5                	mov    %esp,%ebp
f01009fe:	57                   	push   %edi
f01009ff:	56                   	push   %esi
f0100a00:	53                   	push   %ebx
f0100a01:	83 ec 14             	sub    $0x14,%esp
f0100a04:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0100a07:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0100a0a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100a0d:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0100a10:	8b 1a                	mov    (%edx),%ebx
f0100a12:	8b 01                	mov    (%ecx),%eax
f0100a14:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a17:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100a1e:	eb 7f                	jmp    f0100a9f <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a23:	01 d8                	add    %ebx,%eax
f0100a25:	89 c6                	mov    %eax,%esi
f0100a27:	c1 ee 1f             	shr    $0x1f,%esi
f0100a2a:	01 c6                	add    %eax,%esi
f0100a2c:	d1 fe                	sar    %esi
f0100a2e:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a31:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a34:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100a37:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a39:	eb 03                	jmp    f0100a3e <stab_binsearch+0x43>
			m--;
f0100a3b:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a3e:	39 c3                	cmp    %eax,%ebx
f0100a40:	7f 0d                	jg     f0100a4f <stab_binsearch+0x54>
f0100a42:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100a46:	83 ea 0c             	sub    $0xc,%edx
f0100a49:	39 f9                	cmp    %edi,%ecx
f0100a4b:	75 ee                	jne    f0100a3b <stab_binsearch+0x40>
f0100a4d:	eb 05                	jmp    f0100a54 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a4f:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100a52:	eb 4b                	jmp    f0100a9f <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a54:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a57:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a5a:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a5e:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a61:	76 11                	jbe    f0100a74 <stab_binsearch+0x79>
			*region_left = m;
f0100a63:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a66:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a68:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a6b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a72:	eb 2b                	jmp    f0100a9f <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a74:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a77:	73 14                	jae    f0100a8d <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a79:	83 e8 01             	sub    $0x1,%eax
f0100a7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a7f:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a82:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a84:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a8b:	eb 12                	jmp    f0100a9f <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a8d:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a90:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a92:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a96:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a98:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a9f:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100aa2:	0f 8e 78 ff ff ff    	jle    f0100a20 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100aa8:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100aac:	75 0f                	jne    f0100abd <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100aae:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100ab1:	8b 00                	mov    (%eax),%eax
f0100ab3:	83 e8 01             	sub    $0x1,%eax
f0100ab6:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100ab9:	89 06                	mov    %eax,(%esi)
f0100abb:	eb 2c                	jmp    f0100ae9 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100abd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ac0:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100ac2:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ac5:	8b 0e                	mov    (%esi),%ecx
f0100ac7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100aca:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100acd:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ad0:	eb 03                	jmp    f0100ad5 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100ad2:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ad5:	39 c8                	cmp    %ecx,%eax
f0100ad7:	7e 0b                	jle    f0100ae4 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100ad9:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100add:	83 ea 0c             	sub    $0xc,%edx
f0100ae0:	39 df                	cmp    %ebx,%edi
f0100ae2:	75 ee                	jne    f0100ad2 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100ae4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100ae7:	89 06                	mov    %eax,(%esi)
	}
}
f0100ae9:	83 c4 14             	add    $0x14,%esp
f0100aec:	5b                   	pop    %ebx
f0100aed:	5e                   	pop    %esi
f0100aee:	5f                   	pop    %edi
f0100aef:	5d                   	pop    %ebp
f0100af0:	c3                   	ret    

f0100af1 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100af1:	55                   	push   %ebp
f0100af2:	89 e5                	mov    %esp,%ebp
f0100af4:	57                   	push   %edi
f0100af5:	56                   	push   %esi
f0100af6:	53                   	push   %ebx
f0100af7:	83 ec 3c             	sub    $0x3c,%esp
f0100afa:	8b 75 08             	mov    0x8(%ebp),%esi
f0100afd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100b00:	c7 03 58 1e 10 f0    	movl   $0xf0101e58,(%ebx)
	info->eip_line = 0;
f0100b06:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100b0d:	c7 43 08 58 1e 10 f0 	movl   $0xf0101e58,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100b14:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100b1b:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100b1e:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b25:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b2b:	76 11                	jbe    f0100b3e <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b2d:	b8 f2 73 10 f0       	mov    $0xf01073f2,%eax
f0100b32:	3d c5 5a 10 f0       	cmp    $0xf0105ac5,%eax
f0100b37:	77 19                	ja     f0100b52 <debuginfo_eip+0x61>
f0100b39:	e9 aa 01 00 00       	jmp    f0100ce8 <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b3e:	83 ec 04             	sub    $0x4,%esp
f0100b41:	68 62 1e 10 f0       	push   $0xf0101e62
f0100b46:	6a 7f                	push   $0x7f
f0100b48:	68 6f 1e 10 f0       	push   $0xf0101e6f
f0100b4d:	e8 94 f5 ff ff       	call   f01000e6 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b52:	80 3d f1 73 10 f0 00 	cmpb   $0x0,0xf01073f1
f0100b59:	0f 85 90 01 00 00    	jne    f0100cef <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b5f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b66:	b8 c4 5a 10 f0       	mov    $0xf0105ac4,%eax
f0100b6b:	2d b0 20 10 f0       	sub    $0xf01020b0,%eax
f0100b70:	c1 f8 02             	sar    $0x2,%eax
f0100b73:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b79:	83 e8 01             	sub    $0x1,%eax
f0100b7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b7f:	83 ec 08             	sub    $0x8,%esp
f0100b82:	56                   	push   %esi
f0100b83:	6a 64                	push   $0x64
f0100b85:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b88:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b8b:	b8 b0 20 10 f0       	mov    $0xf01020b0,%eax
f0100b90:	e8 66 fe ff ff       	call   f01009fb <stab_binsearch>
	if (lfile == 0)
f0100b95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b98:	83 c4 10             	add    $0x10,%esp
f0100b9b:	85 c0                	test   %eax,%eax
f0100b9d:	0f 84 53 01 00 00    	je     f0100cf6 <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100ba3:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100ba6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ba9:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100bac:	83 ec 08             	sub    $0x8,%esp
f0100baf:	56                   	push   %esi
f0100bb0:	6a 24                	push   $0x24
f0100bb2:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100bb5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100bb8:	b8 b0 20 10 f0       	mov    $0xf01020b0,%eax
f0100bbd:	e8 39 fe ff ff       	call   f01009fb <stab_binsearch>

	if (lfun <= rfun) {
f0100bc2:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100bc5:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100bc8:	83 c4 10             	add    $0x10,%esp
f0100bcb:	39 d0                	cmp    %edx,%eax
f0100bcd:	7f 40                	jg     f0100c0f <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100bcf:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100bd2:	c1 e1 02             	shl    $0x2,%ecx
f0100bd5:	8d b9 b0 20 10 f0    	lea    -0xfefdf50(%ecx),%edi
f0100bdb:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100bde:	8b b9 b0 20 10 f0    	mov    -0xfefdf50(%ecx),%edi
f0100be4:	b9 f2 73 10 f0       	mov    $0xf01073f2,%ecx
f0100be9:	81 e9 c5 5a 10 f0    	sub    $0xf0105ac5,%ecx
f0100bef:	39 cf                	cmp    %ecx,%edi
f0100bf1:	73 09                	jae    f0100bfc <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100bf3:	81 c7 c5 5a 10 f0    	add    $0xf0105ac5,%edi
f0100bf9:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100bfc:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100bff:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100c02:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100c05:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100c07:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100c0a:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100c0d:	eb 0f                	jmp    f0100c1e <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100c0f:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100c12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100c15:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100c18:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100c1b:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c1e:	83 ec 08             	sub    $0x8,%esp
f0100c21:	6a 3a                	push   $0x3a
f0100c23:	ff 73 08             	pushl  0x8(%ebx)
f0100c26:	e8 59 08 00 00       	call   f0101484 <strfind>
f0100c2b:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c2e:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100c31:	83 c4 08             	add    $0x8,%esp
f0100c34:	56                   	push   %esi
f0100c35:	6a 44                	push   $0x44
f0100c37:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100c3a:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100c3d:	b8 b0 20 10 f0       	mov    $0xf01020b0,%eax
f0100c42:	e8 b4 fd ff ff       	call   f01009fb <stab_binsearch>
	if (lline <= rline) {
f0100c47:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100c4a:	83 c4 10             	add    $0x10,%esp
f0100c4d:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100c50:	0f 8f a7 00 00 00    	jg     f0100cfd <debuginfo_eip+0x20c>
		info->eip_line = stabs[lline].n_desc;
f0100c56:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c59:	8d 04 85 b0 20 10 f0 	lea    -0xfefdf50(,%eax,4),%eax
f0100c60:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100c64:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c67:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c6a:	eb 06                	jmp    f0100c72 <debuginfo_eip+0x181>
f0100c6c:	83 ea 01             	sub    $0x1,%edx
f0100c6f:	83 e8 0c             	sub    $0xc,%eax
f0100c72:	39 d6                	cmp    %edx,%esi
f0100c74:	7f 34                	jg     f0100caa <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f0100c76:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c7a:	80 f9 84             	cmp    $0x84,%cl
f0100c7d:	74 0b                	je     f0100c8a <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c7f:	80 f9 64             	cmp    $0x64,%cl
f0100c82:	75 e8                	jne    f0100c6c <debuginfo_eip+0x17b>
f0100c84:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c88:	74 e2                	je     f0100c6c <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c8a:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c8d:	8b 14 85 b0 20 10 f0 	mov    -0xfefdf50(,%eax,4),%edx
f0100c94:	b8 f2 73 10 f0       	mov    $0xf01073f2,%eax
f0100c99:	2d c5 5a 10 f0       	sub    $0xf0105ac5,%eax
f0100c9e:	39 c2                	cmp    %eax,%edx
f0100ca0:	73 08                	jae    f0100caa <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100ca2:	81 c2 c5 5a 10 f0    	add    $0xf0105ac5,%edx
f0100ca8:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100caa:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100cad:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cb0:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100cb5:	39 f2                	cmp    %esi,%edx
f0100cb7:	7d 50                	jge    f0100d09 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f0100cb9:	83 c2 01             	add    $0x1,%edx
f0100cbc:	89 d0                	mov    %edx,%eax
f0100cbe:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100cc1:	8d 14 95 b0 20 10 f0 	lea    -0xfefdf50(,%edx,4),%edx
f0100cc8:	eb 04                	jmp    f0100cce <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100cca:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100cce:	39 c6                	cmp    %eax,%esi
f0100cd0:	7e 32                	jle    f0100d04 <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100cd2:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100cd6:	83 c0 01             	add    $0x1,%eax
f0100cd9:	83 c2 0c             	add    $0xc,%edx
f0100cdc:	80 f9 a0             	cmp    $0xa0,%cl
f0100cdf:	74 e9                	je     f0100cca <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100ce1:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ce6:	eb 21                	jmp    f0100d09 <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100ce8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ced:	eb 1a                	jmp    f0100d09 <debuginfo_eip+0x218>
f0100cef:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cf4:	eb 13                	jmp    f0100d09 <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100cf6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cfb:	eb 0c                	jmp    f0100d09 <debuginfo_eip+0x218>
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;
f0100cfd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100d02:	eb 05                	jmp    f0100d09 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100d04:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100d09:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d0c:	5b                   	pop    %ebx
f0100d0d:	5e                   	pop    %esi
f0100d0e:	5f                   	pop    %edi
f0100d0f:	5d                   	pop    %ebp
f0100d10:	c3                   	ret    

f0100d11 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100d11:	55                   	push   %ebp
f0100d12:	89 e5                	mov    %esp,%ebp
f0100d14:	57                   	push   %edi
f0100d15:	56                   	push   %esi
f0100d16:	53                   	push   %ebx
f0100d17:	83 ec 1c             	sub    $0x1c,%esp
f0100d1a:	89 c7                	mov    %eax,%edi
f0100d1c:	89 d6                	mov    %edx,%esi
f0100d1e:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d21:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d24:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100d27:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100d2d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d32:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100d35:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100d38:	39 d3                	cmp    %edx,%ebx
f0100d3a:	72 05                	jb     f0100d41 <printnum+0x30>
f0100d3c:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100d3f:	77 45                	ja     f0100d86 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d41:	83 ec 0c             	sub    $0xc,%esp
f0100d44:	ff 75 18             	pushl  0x18(%ebp)
f0100d47:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d4a:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100d4d:	53                   	push   %ebx
f0100d4e:	ff 75 10             	pushl  0x10(%ebp)
f0100d51:	83 ec 08             	sub    $0x8,%esp
f0100d54:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d57:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d5a:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d5d:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d60:	e8 4b 09 00 00       	call   f01016b0 <__udivdi3>
f0100d65:	83 c4 18             	add    $0x18,%esp
f0100d68:	52                   	push   %edx
f0100d69:	50                   	push   %eax
f0100d6a:	89 f2                	mov    %esi,%edx
f0100d6c:	89 f8                	mov    %edi,%eax
f0100d6e:	e8 9e ff ff ff       	call   f0100d11 <printnum>
f0100d73:	83 c4 20             	add    $0x20,%esp
f0100d76:	eb 18                	jmp    f0100d90 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d78:	83 ec 08             	sub    $0x8,%esp
f0100d7b:	56                   	push   %esi
f0100d7c:	ff 75 18             	pushl  0x18(%ebp)
f0100d7f:	ff d7                	call   *%edi
f0100d81:	83 c4 10             	add    $0x10,%esp
f0100d84:	eb 03                	jmp    f0100d89 <printnum+0x78>
f0100d86:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d89:	83 eb 01             	sub    $0x1,%ebx
f0100d8c:	85 db                	test   %ebx,%ebx
f0100d8e:	7f e8                	jg     f0100d78 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d90:	83 ec 08             	sub    $0x8,%esp
f0100d93:	56                   	push   %esi
f0100d94:	83 ec 04             	sub    $0x4,%esp
f0100d97:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d9a:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d9d:	ff 75 dc             	pushl  -0x24(%ebp)
f0100da0:	ff 75 d8             	pushl  -0x28(%ebp)
f0100da3:	e8 38 0a 00 00       	call   f01017e0 <__umoddi3>
f0100da8:	83 c4 14             	add    $0x14,%esp
f0100dab:	0f be 80 7d 1e 10 f0 	movsbl -0xfefe183(%eax),%eax
f0100db2:	50                   	push   %eax
f0100db3:	ff d7                	call   *%edi
}
f0100db5:	83 c4 10             	add    $0x10,%esp
f0100db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dbb:	5b                   	pop    %ebx
f0100dbc:	5e                   	pop    %esi
f0100dbd:	5f                   	pop    %edi
f0100dbe:	5d                   	pop    %ebp
f0100dbf:	c3                   	ret    

f0100dc0 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100dc0:	55                   	push   %ebp
f0100dc1:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100dc3:	83 fa 01             	cmp    $0x1,%edx
f0100dc6:	7e 0e                	jle    f0100dd6 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100dc8:	8b 10                	mov    (%eax),%edx
f0100dca:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100dcd:	89 08                	mov    %ecx,(%eax)
f0100dcf:	8b 02                	mov    (%edx),%eax
f0100dd1:	8b 52 04             	mov    0x4(%edx),%edx
f0100dd4:	eb 22                	jmp    f0100df8 <getuint+0x38>
	else if (lflag)
f0100dd6:	85 d2                	test   %edx,%edx
f0100dd8:	74 10                	je     f0100dea <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100dda:	8b 10                	mov    (%eax),%edx
f0100ddc:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100ddf:	89 08                	mov    %ecx,(%eax)
f0100de1:	8b 02                	mov    (%edx),%eax
f0100de3:	ba 00 00 00 00       	mov    $0x0,%edx
f0100de8:	eb 0e                	jmp    f0100df8 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100dea:	8b 10                	mov    (%eax),%edx
f0100dec:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100def:	89 08                	mov    %ecx,(%eax)
f0100df1:	8b 02                	mov    (%edx),%eax
f0100df3:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100df8:	5d                   	pop    %ebp
f0100df9:	c3                   	ret    

f0100dfa <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100dfa:	55                   	push   %ebp
f0100dfb:	89 e5                	mov    %esp,%ebp
f0100dfd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100e00:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100e04:	8b 10                	mov    (%eax),%edx
f0100e06:	3b 50 04             	cmp    0x4(%eax),%edx
f0100e09:	73 0a                	jae    f0100e15 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100e0b:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100e0e:	89 08                	mov    %ecx,(%eax)
f0100e10:	8b 45 08             	mov    0x8(%ebp),%eax
f0100e13:	88 02                	mov    %al,(%edx)
}
f0100e15:	5d                   	pop    %ebp
f0100e16:	c3                   	ret    

f0100e17 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100e17:	55                   	push   %ebp
f0100e18:	89 e5                	mov    %esp,%ebp
f0100e1a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100e1d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e20:	50                   	push   %eax
f0100e21:	ff 75 10             	pushl  0x10(%ebp)
f0100e24:	ff 75 0c             	pushl  0xc(%ebp)
f0100e27:	ff 75 08             	pushl  0x8(%ebp)
f0100e2a:	e8 05 00 00 00       	call   f0100e34 <vprintfmt>
	va_end(ap);
}
f0100e2f:	83 c4 10             	add    $0x10,%esp
f0100e32:	c9                   	leave  
f0100e33:	c3                   	ret    

f0100e34 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100e34:	55                   	push   %ebp
f0100e35:	89 e5                	mov    %esp,%ebp
f0100e37:	57                   	push   %edi
f0100e38:	56                   	push   %esi
f0100e39:	53                   	push   %ebx
f0100e3a:	83 ec 2c             	sub    $0x2c,%esp
f0100e3d:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e43:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100e46:	eb 12                	jmp    f0100e5a <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e48:	85 c0                	test   %eax,%eax
f0100e4a:	0f 84 89 03 00 00    	je     f01011d9 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100e50:	83 ec 08             	sub    $0x8,%esp
f0100e53:	53                   	push   %ebx
f0100e54:	50                   	push   %eax
f0100e55:	ff d6                	call   *%esi
f0100e57:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e5a:	83 c7 01             	add    $0x1,%edi
f0100e5d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100e61:	83 f8 25             	cmp    $0x25,%eax
f0100e64:	75 e2                	jne    f0100e48 <vprintfmt+0x14>
f0100e66:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e6a:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e71:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e78:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e7f:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e84:	eb 07                	jmp    f0100e8d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e86:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e89:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e8d:	8d 47 01             	lea    0x1(%edi),%eax
f0100e90:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e93:	0f b6 07             	movzbl (%edi),%eax
f0100e96:	0f b6 c8             	movzbl %al,%ecx
f0100e99:	83 e8 23             	sub    $0x23,%eax
f0100e9c:	3c 55                	cmp    $0x55,%al
f0100e9e:	0f 87 1a 03 00 00    	ja     f01011be <vprintfmt+0x38a>
f0100ea4:	0f b6 c0             	movzbl %al,%eax
f0100ea7:	ff 24 85 20 1f 10 f0 	jmp    *-0xfefe0e0(,%eax,4)
f0100eae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100eb1:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100eb5:	eb d6                	jmp    f0100e8d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100eb7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100eba:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ebf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100ec2:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100ec5:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100ec9:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100ecc:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100ecf:	83 fa 09             	cmp    $0x9,%edx
f0100ed2:	77 39                	ja     f0100f0d <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100ed4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100ed7:	eb e9                	jmp    f0100ec2 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100ed9:	8b 45 14             	mov    0x14(%ebp),%eax
f0100edc:	8d 48 04             	lea    0x4(%eax),%ecx
f0100edf:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100ee2:	8b 00                	mov    (%eax),%eax
f0100ee4:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ee7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100eea:	eb 27                	jmp    f0100f13 <vprintfmt+0xdf>
f0100eec:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100eef:	85 c0                	test   %eax,%eax
f0100ef1:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ef6:	0f 49 c8             	cmovns %eax,%ecx
f0100ef9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100efc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100eff:	eb 8c                	jmp    f0100e8d <vprintfmt+0x59>
f0100f01:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100f04:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100f0b:	eb 80                	jmp    f0100e8d <vprintfmt+0x59>
f0100f0d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100f10:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100f13:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100f17:	0f 89 70 ff ff ff    	jns    f0100e8d <vprintfmt+0x59>
				width = precision, precision = -1;
f0100f1d:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100f20:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f23:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100f2a:	e9 5e ff ff ff       	jmp    f0100e8d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f2f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100f35:	e9 53 ff ff ff       	jmp    f0100e8d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f3a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f3d:	8d 50 04             	lea    0x4(%eax),%edx
f0100f40:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f43:	83 ec 08             	sub    $0x8,%esp
f0100f46:	53                   	push   %ebx
f0100f47:	ff 30                	pushl  (%eax)
f0100f49:	ff d6                	call   *%esi
			break;
f0100f4b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100f51:	e9 04 ff ff ff       	jmp    f0100e5a <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f56:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f59:	8d 50 04             	lea    0x4(%eax),%edx
f0100f5c:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f5f:	8b 00                	mov    (%eax),%eax
f0100f61:	99                   	cltd   
f0100f62:	31 d0                	xor    %edx,%eax
f0100f64:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f66:	83 f8 07             	cmp    $0x7,%eax
f0100f69:	7f 0b                	jg     f0100f76 <vprintfmt+0x142>
f0100f6b:	8b 14 85 80 20 10 f0 	mov    -0xfefdf80(,%eax,4),%edx
f0100f72:	85 d2                	test   %edx,%edx
f0100f74:	75 18                	jne    f0100f8e <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f76:	50                   	push   %eax
f0100f77:	68 95 1e 10 f0       	push   $0xf0101e95
f0100f7c:	53                   	push   %ebx
f0100f7d:	56                   	push   %esi
f0100f7e:	e8 94 fe ff ff       	call   f0100e17 <printfmt>
f0100f83:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f86:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f89:	e9 cc fe ff ff       	jmp    f0100e5a <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f8e:	52                   	push   %edx
f0100f8f:	68 9e 1e 10 f0       	push   $0xf0101e9e
f0100f94:	53                   	push   %ebx
f0100f95:	56                   	push   %esi
f0100f96:	e8 7c fe ff ff       	call   f0100e17 <printfmt>
f0100f9b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100fa1:	e9 b4 fe ff ff       	jmp    f0100e5a <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100fa6:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fa9:	8d 50 04             	lea    0x4(%eax),%edx
f0100fac:	89 55 14             	mov    %edx,0x14(%ebp)
f0100faf:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100fb1:	85 ff                	test   %edi,%edi
f0100fb3:	b8 8e 1e 10 f0       	mov    $0xf0101e8e,%eax
f0100fb8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100fbb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100fbf:	0f 8e 94 00 00 00    	jle    f0101059 <vprintfmt+0x225>
f0100fc5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100fc9:	0f 84 98 00 00 00    	je     f0101067 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fcf:	83 ec 08             	sub    $0x8,%esp
f0100fd2:	ff 75 d0             	pushl  -0x30(%ebp)
f0100fd5:	57                   	push   %edi
f0100fd6:	e8 5f 03 00 00       	call   f010133a <strnlen>
f0100fdb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fde:	29 c1                	sub    %eax,%ecx
f0100fe0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100fe3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100fe6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100fea:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fed:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100ff0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ff2:	eb 0f                	jmp    f0101003 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100ff4:	83 ec 08             	sub    $0x8,%esp
f0100ff7:	53                   	push   %ebx
f0100ff8:	ff 75 e0             	pushl  -0x20(%ebp)
f0100ffb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100ffd:	83 ef 01             	sub    $0x1,%edi
f0101000:	83 c4 10             	add    $0x10,%esp
f0101003:	85 ff                	test   %edi,%edi
f0101005:	7f ed                	jg     f0100ff4 <vprintfmt+0x1c0>
f0101007:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010100a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010100d:	85 c9                	test   %ecx,%ecx
f010100f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101014:	0f 49 c1             	cmovns %ecx,%eax
f0101017:	29 c1                	sub    %eax,%ecx
f0101019:	89 75 08             	mov    %esi,0x8(%ebp)
f010101c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010101f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101022:	89 cb                	mov    %ecx,%ebx
f0101024:	eb 4d                	jmp    f0101073 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101026:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010102a:	74 1b                	je     f0101047 <vprintfmt+0x213>
f010102c:	0f be c0             	movsbl %al,%eax
f010102f:	83 e8 20             	sub    $0x20,%eax
f0101032:	83 f8 5e             	cmp    $0x5e,%eax
f0101035:	76 10                	jbe    f0101047 <vprintfmt+0x213>
					putch('?', putdat);
f0101037:	83 ec 08             	sub    $0x8,%esp
f010103a:	ff 75 0c             	pushl  0xc(%ebp)
f010103d:	6a 3f                	push   $0x3f
f010103f:	ff 55 08             	call   *0x8(%ebp)
f0101042:	83 c4 10             	add    $0x10,%esp
f0101045:	eb 0d                	jmp    f0101054 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0101047:	83 ec 08             	sub    $0x8,%esp
f010104a:	ff 75 0c             	pushl  0xc(%ebp)
f010104d:	52                   	push   %edx
f010104e:	ff 55 08             	call   *0x8(%ebp)
f0101051:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101054:	83 eb 01             	sub    $0x1,%ebx
f0101057:	eb 1a                	jmp    f0101073 <vprintfmt+0x23f>
f0101059:	89 75 08             	mov    %esi,0x8(%ebp)
f010105c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010105f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101062:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101065:	eb 0c                	jmp    f0101073 <vprintfmt+0x23f>
f0101067:	89 75 08             	mov    %esi,0x8(%ebp)
f010106a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f010106d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101070:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101073:	83 c7 01             	add    $0x1,%edi
f0101076:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010107a:	0f be d0             	movsbl %al,%edx
f010107d:	85 d2                	test   %edx,%edx
f010107f:	74 23                	je     f01010a4 <vprintfmt+0x270>
f0101081:	85 f6                	test   %esi,%esi
f0101083:	78 a1                	js     f0101026 <vprintfmt+0x1f2>
f0101085:	83 ee 01             	sub    $0x1,%esi
f0101088:	79 9c                	jns    f0101026 <vprintfmt+0x1f2>
f010108a:	89 df                	mov    %ebx,%edi
f010108c:	8b 75 08             	mov    0x8(%ebp),%esi
f010108f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101092:	eb 18                	jmp    f01010ac <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101094:	83 ec 08             	sub    $0x8,%esp
f0101097:	53                   	push   %ebx
f0101098:	6a 20                	push   $0x20
f010109a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010109c:	83 ef 01             	sub    $0x1,%edi
f010109f:	83 c4 10             	add    $0x10,%esp
f01010a2:	eb 08                	jmp    f01010ac <vprintfmt+0x278>
f01010a4:	89 df                	mov    %ebx,%edi
f01010a6:	8b 75 08             	mov    0x8(%ebp),%esi
f01010a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01010ac:	85 ff                	test   %edi,%edi
f01010ae:	7f e4                	jg     f0101094 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01010b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01010b3:	e9 a2 fd ff ff       	jmp    f0100e5a <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01010b8:	83 fa 01             	cmp    $0x1,%edx
f01010bb:	7e 16                	jle    f01010d3 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01010bd:	8b 45 14             	mov    0x14(%ebp),%eax
f01010c0:	8d 50 08             	lea    0x8(%eax),%edx
f01010c3:	89 55 14             	mov    %edx,0x14(%ebp)
f01010c6:	8b 50 04             	mov    0x4(%eax),%edx
f01010c9:	8b 00                	mov    (%eax),%eax
f01010cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010d1:	eb 32                	jmp    f0101105 <vprintfmt+0x2d1>
	else if (lflag)
f01010d3:	85 d2                	test   %edx,%edx
f01010d5:	74 18                	je     f01010ef <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01010d7:	8b 45 14             	mov    0x14(%ebp),%eax
f01010da:	8d 50 04             	lea    0x4(%eax),%edx
f01010dd:	89 55 14             	mov    %edx,0x14(%ebp)
f01010e0:	8b 00                	mov    (%eax),%eax
f01010e2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010e5:	89 c1                	mov    %eax,%ecx
f01010e7:	c1 f9 1f             	sar    $0x1f,%ecx
f01010ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01010ed:	eb 16                	jmp    f0101105 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01010ef:	8b 45 14             	mov    0x14(%ebp),%eax
f01010f2:	8d 50 04             	lea    0x4(%eax),%edx
f01010f5:	89 55 14             	mov    %edx,0x14(%ebp)
f01010f8:	8b 00                	mov    (%eax),%eax
f01010fa:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010fd:	89 c1                	mov    %eax,%ecx
f01010ff:	c1 f9 1f             	sar    $0x1f,%ecx
f0101102:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101105:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101108:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f010110b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101110:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101114:	79 74                	jns    f010118a <vprintfmt+0x356>
				putch('-', putdat);
f0101116:	83 ec 08             	sub    $0x8,%esp
f0101119:	53                   	push   %ebx
f010111a:	6a 2d                	push   $0x2d
f010111c:	ff d6                	call   *%esi
				num = -(long long) num;
f010111e:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101121:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101124:	f7 d8                	neg    %eax
f0101126:	83 d2 00             	adc    $0x0,%edx
f0101129:	f7 da                	neg    %edx
f010112b:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f010112e:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101133:	eb 55                	jmp    f010118a <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101135:	8d 45 14             	lea    0x14(%ebp),%eax
f0101138:	e8 83 fc ff ff       	call   f0100dc0 <getuint>
			base = 10;
f010113d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101142:	eb 46                	jmp    f010118a <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.		       
			num = getuint(&ap, lflag);
f0101144:	8d 45 14             	lea    0x14(%ebp),%eax
f0101147:	e8 74 fc ff ff       	call   f0100dc0 <getuint>
			base = 8;
f010114c:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101151:	eb 37                	jmp    f010118a <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0101153:	83 ec 08             	sub    $0x8,%esp
f0101156:	53                   	push   %ebx
f0101157:	6a 30                	push   $0x30
f0101159:	ff d6                	call   *%esi
			putch('x', putdat);
f010115b:	83 c4 08             	add    $0x8,%esp
f010115e:	53                   	push   %ebx
f010115f:	6a 78                	push   $0x78
f0101161:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101163:	8b 45 14             	mov    0x14(%ebp),%eax
f0101166:	8d 50 04             	lea    0x4(%eax),%edx
f0101169:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f010116c:	8b 00                	mov    (%eax),%eax
f010116e:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101173:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101176:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010117b:	eb 0d                	jmp    f010118a <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f010117d:	8d 45 14             	lea    0x14(%ebp),%eax
f0101180:	e8 3b fc ff ff       	call   f0100dc0 <getuint>
			base = 16;
f0101185:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010118a:	83 ec 0c             	sub    $0xc,%esp
f010118d:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101191:	57                   	push   %edi
f0101192:	ff 75 e0             	pushl  -0x20(%ebp)
f0101195:	51                   	push   %ecx
f0101196:	52                   	push   %edx
f0101197:	50                   	push   %eax
f0101198:	89 da                	mov    %ebx,%edx
f010119a:	89 f0                	mov    %esi,%eax
f010119c:	e8 70 fb ff ff       	call   f0100d11 <printnum>
			break;
f01011a1:	83 c4 20             	add    $0x20,%esp
f01011a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01011a7:	e9 ae fc ff ff       	jmp    f0100e5a <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01011ac:	83 ec 08             	sub    $0x8,%esp
f01011af:	53                   	push   %ebx
f01011b0:	51                   	push   %ecx
f01011b1:	ff d6                	call   *%esi
			break;
f01011b3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01011b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f01011b9:	e9 9c fc ff ff       	jmp    f0100e5a <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01011be:	83 ec 08             	sub    $0x8,%esp
f01011c1:	53                   	push   %ebx
f01011c2:	6a 25                	push   $0x25
f01011c4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01011c6:	83 c4 10             	add    $0x10,%esp
f01011c9:	eb 03                	jmp    f01011ce <vprintfmt+0x39a>
f01011cb:	83 ef 01             	sub    $0x1,%edi
f01011ce:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01011d2:	75 f7                	jne    f01011cb <vprintfmt+0x397>
f01011d4:	e9 81 fc ff ff       	jmp    f0100e5a <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011dc:	5b                   	pop    %ebx
f01011dd:	5e                   	pop    %esi
f01011de:	5f                   	pop    %edi
f01011df:	5d                   	pop    %ebp
f01011e0:	c3                   	ret    

f01011e1 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01011e1:	55                   	push   %ebp
f01011e2:	89 e5                	mov    %esp,%ebp
f01011e4:	83 ec 18             	sub    $0x18,%esp
f01011e7:	8b 45 08             	mov    0x8(%ebp),%eax
f01011ea:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01011ed:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01011f0:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01011f4:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01011f7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01011fe:	85 c0                	test   %eax,%eax
f0101200:	74 26                	je     f0101228 <vsnprintf+0x47>
f0101202:	85 d2                	test   %edx,%edx
f0101204:	7e 22                	jle    f0101228 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101206:	ff 75 14             	pushl  0x14(%ebp)
f0101209:	ff 75 10             	pushl  0x10(%ebp)
f010120c:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010120f:	50                   	push   %eax
f0101210:	68 fa 0d 10 f0       	push   $0xf0100dfa
f0101215:	e8 1a fc ff ff       	call   f0100e34 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010121a:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010121d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101220:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101223:	83 c4 10             	add    $0x10,%esp
f0101226:	eb 05                	jmp    f010122d <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101228:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f010122d:	c9                   	leave  
f010122e:	c3                   	ret    

f010122f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f010122f:	55                   	push   %ebp
f0101230:	89 e5                	mov    %esp,%ebp
f0101232:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101235:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101238:	50                   	push   %eax
f0101239:	ff 75 10             	pushl  0x10(%ebp)
f010123c:	ff 75 0c             	pushl  0xc(%ebp)
f010123f:	ff 75 08             	pushl  0x8(%ebp)
f0101242:	e8 9a ff ff ff       	call   f01011e1 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101247:	c9                   	leave  
f0101248:	c3                   	ret    

f0101249 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101249:	55                   	push   %ebp
f010124a:	89 e5                	mov    %esp,%ebp
f010124c:	57                   	push   %edi
f010124d:	56                   	push   %esi
f010124e:	53                   	push   %ebx
f010124f:	83 ec 0c             	sub    $0xc,%esp
f0101252:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101255:	85 c0                	test   %eax,%eax
f0101257:	74 11                	je     f010126a <readline+0x21>
		cprintf("%s", prompt);
f0101259:	83 ec 08             	sub    $0x8,%esp
f010125c:	50                   	push   %eax
f010125d:	68 9e 1e 10 f0       	push   $0xf0101e9e
f0101262:	e8 80 f7 ff ff       	call   f01009e7 <cprintf>
f0101267:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010126a:	83 ec 0c             	sub    $0xc,%esp
f010126d:	6a 00                	push   $0x0
f010126f:	e8 fa f3 ff ff       	call   f010066e <iscons>
f0101274:	89 c7                	mov    %eax,%edi
f0101276:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101279:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f010127e:	e8 da f3 ff ff       	call   f010065d <getchar>
f0101283:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101285:	85 c0                	test   %eax,%eax
f0101287:	79 18                	jns    f01012a1 <readline+0x58>
			cprintf("read error: %e\n", c);
f0101289:	83 ec 08             	sub    $0x8,%esp
f010128c:	50                   	push   %eax
f010128d:	68 a0 20 10 f0       	push   $0xf01020a0
f0101292:	e8 50 f7 ff ff       	call   f01009e7 <cprintf>
			return NULL;
f0101297:	83 c4 10             	add    $0x10,%esp
f010129a:	b8 00 00 00 00       	mov    $0x0,%eax
f010129f:	eb 79                	jmp    f010131a <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f01012a1:	83 f8 08             	cmp    $0x8,%eax
f01012a4:	0f 94 c2             	sete   %dl
f01012a7:	83 f8 7f             	cmp    $0x7f,%eax
f01012aa:	0f 94 c0             	sete   %al
f01012ad:	08 c2                	or     %al,%dl
f01012af:	74 1a                	je     f01012cb <readline+0x82>
f01012b1:	85 f6                	test   %esi,%esi
f01012b3:	7e 16                	jle    f01012cb <readline+0x82>
			if (echoing)
f01012b5:	85 ff                	test   %edi,%edi
f01012b7:	74 0d                	je     f01012c6 <readline+0x7d>
				cputchar('\b');
f01012b9:	83 ec 0c             	sub    $0xc,%esp
f01012bc:	6a 08                	push   $0x8
f01012be:	e8 8a f3 ff ff       	call   f010064d <cputchar>
f01012c3:	83 c4 10             	add    $0x10,%esp
			i--;
f01012c6:	83 ee 01             	sub    $0x1,%esi
f01012c9:	eb b3                	jmp    f010127e <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01012cb:	83 fb 1f             	cmp    $0x1f,%ebx
f01012ce:	7e 23                	jle    f01012f3 <readline+0xaa>
f01012d0:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01012d6:	7f 1b                	jg     f01012f3 <readline+0xaa>
			if (echoing)
f01012d8:	85 ff                	test   %edi,%edi
f01012da:	74 0c                	je     f01012e8 <readline+0x9f>
				cputchar(c);
f01012dc:	83 ec 0c             	sub    $0xc,%esp
f01012df:	53                   	push   %ebx
f01012e0:	e8 68 f3 ff ff       	call   f010064d <cputchar>
f01012e5:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01012e8:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01012ee:	8d 76 01             	lea    0x1(%esi),%esi
f01012f1:	eb 8b                	jmp    f010127e <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01012f3:	83 fb 0a             	cmp    $0xa,%ebx
f01012f6:	74 05                	je     f01012fd <readline+0xb4>
f01012f8:	83 fb 0d             	cmp    $0xd,%ebx
f01012fb:	75 81                	jne    f010127e <readline+0x35>
			if (echoing)
f01012fd:	85 ff                	test   %edi,%edi
f01012ff:	74 0d                	je     f010130e <readline+0xc5>
				cputchar('\n');
f0101301:	83 ec 0c             	sub    $0xc,%esp
f0101304:	6a 0a                	push   $0xa
f0101306:	e8 42 f3 ff ff       	call   f010064d <cputchar>
f010130b:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f010130e:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f0101315:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f010131a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010131d:	5b                   	pop    %ebx
f010131e:	5e                   	pop    %esi
f010131f:	5f                   	pop    %edi
f0101320:	5d                   	pop    %ebp
f0101321:	c3                   	ret    

f0101322 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101322:	55                   	push   %ebp
f0101323:	89 e5                	mov    %esp,%ebp
f0101325:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101328:	b8 00 00 00 00       	mov    $0x0,%eax
f010132d:	eb 03                	jmp    f0101332 <strlen+0x10>
		n++;
f010132f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101332:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101336:	75 f7                	jne    f010132f <strlen+0xd>
		n++;
	return n;
}
f0101338:	5d                   	pop    %ebp
f0101339:	c3                   	ret    

f010133a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010133a:	55                   	push   %ebp
f010133b:	89 e5                	mov    %esp,%ebp
f010133d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101340:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101343:	ba 00 00 00 00       	mov    $0x0,%edx
f0101348:	eb 03                	jmp    f010134d <strnlen+0x13>
		n++;
f010134a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010134d:	39 c2                	cmp    %eax,%edx
f010134f:	74 08                	je     f0101359 <strnlen+0x1f>
f0101351:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101355:	75 f3                	jne    f010134a <strnlen+0x10>
f0101357:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101359:	5d                   	pop    %ebp
f010135a:	c3                   	ret    

f010135b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010135b:	55                   	push   %ebp
f010135c:	89 e5                	mov    %esp,%ebp
f010135e:	53                   	push   %ebx
f010135f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101362:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101365:	89 c2                	mov    %eax,%edx
f0101367:	83 c2 01             	add    $0x1,%edx
f010136a:	83 c1 01             	add    $0x1,%ecx
f010136d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101371:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101374:	84 db                	test   %bl,%bl
f0101376:	75 ef                	jne    f0101367 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101378:	5b                   	pop    %ebx
f0101379:	5d                   	pop    %ebp
f010137a:	c3                   	ret    

f010137b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010137b:	55                   	push   %ebp
f010137c:	89 e5                	mov    %esp,%ebp
f010137e:	53                   	push   %ebx
f010137f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101382:	53                   	push   %ebx
f0101383:	e8 9a ff ff ff       	call   f0101322 <strlen>
f0101388:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010138b:	ff 75 0c             	pushl  0xc(%ebp)
f010138e:	01 d8                	add    %ebx,%eax
f0101390:	50                   	push   %eax
f0101391:	e8 c5 ff ff ff       	call   f010135b <strcpy>
	return dst;
}
f0101396:	89 d8                	mov    %ebx,%eax
f0101398:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010139b:	c9                   	leave  
f010139c:	c3                   	ret    

f010139d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010139d:	55                   	push   %ebp
f010139e:	89 e5                	mov    %esp,%ebp
f01013a0:	56                   	push   %esi
f01013a1:	53                   	push   %ebx
f01013a2:	8b 75 08             	mov    0x8(%ebp),%esi
f01013a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013a8:	89 f3                	mov    %esi,%ebx
f01013aa:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013ad:	89 f2                	mov    %esi,%edx
f01013af:	eb 0f                	jmp    f01013c0 <strncpy+0x23>
		*dst++ = *src;
f01013b1:	83 c2 01             	add    $0x1,%edx
f01013b4:	0f b6 01             	movzbl (%ecx),%eax
f01013b7:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01013ba:	80 39 01             	cmpb   $0x1,(%ecx)
f01013bd:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013c0:	39 da                	cmp    %ebx,%edx
f01013c2:	75 ed                	jne    f01013b1 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01013c4:	89 f0                	mov    %esi,%eax
f01013c6:	5b                   	pop    %ebx
f01013c7:	5e                   	pop    %esi
f01013c8:	5d                   	pop    %ebp
f01013c9:	c3                   	ret    

f01013ca <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01013ca:	55                   	push   %ebp
f01013cb:	89 e5                	mov    %esp,%ebp
f01013cd:	56                   	push   %esi
f01013ce:	53                   	push   %ebx
f01013cf:	8b 75 08             	mov    0x8(%ebp),%esi
f01013d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013d5:	8b 55 10             	mov    0x10(%ebp),%edx
f01013d8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01013da:	85 d2                	test   %edx,%edx
f01013dc:	74 21                	je     f01013ff <strlcpy+0x35>
f01013de:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01013e2:	89 f2                	mov    %esi,%edx
f01013e4:	eb 09                	jmp    f01013ef <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01013e6:	83 c2 01             	add    $0x1,%edx
f01013e9:	83 c1 01             	add    $0x1,%ecx
f01013ec:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01013ef:	39 c2                	cmp    %eax,%edx
f01013f1:	74 09                	je     f01013fc <strlcpy+0x32>
f01013f3:	0f b6 19             	movzbl (%ecx),%ebx
f01013f6:	84 db                	test   %bl,%bl
f01013f8:	75 ec                	jne    f01013e6 <strlcpy+0x1c>
f01013fa:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01013fc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01013ff:	29 f0                	sub    %esi,%eax
}
f0101401:	5b                   	pop    %ebx
f0101402:	5e                   	pop    %esi
f0101403:	5d                   	pop    %ebp
f0101404:	c3                   	ret    

f0101405 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101405:	55                   	push   %ebp
f0101406:	89 e5                	mov    %esp,%ebp
f0101408:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010140b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f010140e:	eb 06                	jmp    f0101416 <strcmp+0x11>
		p++, q++;
f0101410:	83 c1 01             	add    $0x1,%ecx
f0101413:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101416:	0f b6 01             	movzbl (%ecx),%eax
f0101419:	84 c0                	test   %al,%al
f010141b:	74 04                	je     f0101421 <strcmp+0x1c>
f010141d:	3a 02                	cmp    (%edx),%al
f010141f:	74 ef                	je     f0101410 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101421:	0f b6 c0             	movzbl %al,%eax
f0101424:	0f b6 12             	movzbl (%edx),%edx
f0101427:	29 d0                	sub    %edx,%eax
}
f0101429:	5d                   	pop    %ebp
f010142a:	c3                   	ret    

f010142b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010142b:	55                   	push   %ebp
f010142c:	89 e5                	mov    %esp,%ebp
f010142e:	53                   	push   %ebx
f010142f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101432:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101435:	89 c3                	mov    %eax,%ebx
f0101437:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010143a:	eb 06                	jmp    f0101442 <strncmp+0x17>
		n--, p++, q++;
f010143c:	83 c0 01             	add    $0x1,%eax
f010143f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101442:	39 d8                	cmp    %ebx,%eax
f0101444:	74 15                	je     f010145b <strncmp+0x30>
f0101446:	0f b6 08             	movzbl (%eax),%ecx
f0101449:	84 c9                	test   %cl,%cl
f010144b:	74 04                	je     f0101451 <strncmp+0x26>
f010144d:	3a 0a                	cmp    (%edx),%cl
f010144f:	74 eb                	je     f010143c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101451:	0f b6 00             	movzbl (%eax),%eax
f0101454:	0f b6 12             	movzbl (%edx),%edx
f0101457:	29 d0                	sub    %edx,%eax
f0101459:	eb 05                	jmp    f0101460 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010145b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101460:	5b                   	pop    %ebx
f0101461:	5d                   	pop    %ebp
f0101462:	c3                   	ret    

f0101463 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101463:	55                   	push   %ebp
f0101464:	89 e5                	mov    %esp,%ebp
f0101466:	8b 45 08             	mov    0x8(%ebp),%eax
f0101469:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010146d:	eb 07                	jmp    f0101476 <strchr+0x13>
		if (*s == c)
f010146f:	38 ca                	cmp    %cl,%dl
f0101471:	74 0f                	je     f0101482 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101473:	83 c0 01             	add    $0x1,%eax
f0101476:	0f b6 10             	movzbl (%eax),%edx
f0101479:	84 d2                	test   %dl,%dl
f010147b:	75 f2                	jne    f010146f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010147d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101482:	5d                   	pop    %ebp
f0101483:	c3                   	ret    

f0101484 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101484:	55                   	push   %ebp
f0101485:	89 e5                	mov    %esp,%ebp
f0101487:	8b 45 08             	mov    0x8(%ebp),%eax
f010148a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010148e:	eb 03                	jmp    f0101493 <strfind+0xf>
f0101490:	83 c0 01             	add    $0x1,%eax
f0101493:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0101496:	38 ca                	cmp    %cl,%dl
f0101498:	74 04                	je     f010149e <strfind+0x1a>
f010149a:	84 d2                	test   %dl,%dl
f010149c:	75 f2                	jne    f0101490 <strfind+0xc>
			break;
	return (char *) s;
}
f010149e:	5d                   	pop    %ebp
f010149f:	c3                   	ret    

f01014a0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01014a0:	55                   	push   %ebp
f01014a1:	89 e5                	mov    %esp,%ebp
f01014a3:	57                   	push   %edi
f01014a4:	56                   	push   %esi
f01014a5:	53                   	push   %ebx
f01014a6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01014a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01014ac:	85 c9                	test   %ecx,%ecx
f01014ae:	74 36                	je     f01014e6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01014b0:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01014b6:	75 28                	jne    f01014e0 <memset+0x40>
f01014b8:	f6 c1 03             	test   $0x3,%cl
f01014bb:	75 23                	jne    f01014e0 <memset+0x40>
		c &= 0xFF;
f01014bd:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01014c1:	89 d3                	mov    %edx,%ebx
f01014c3:	c1 e3 08             	shl    $0x8,%ebx
f01014c6:	89 d6                	mov    %edx,%esi
f01014c8:	c1 e6 18             	shl    $0x18,%esi
f01014cb:	89 d0                	mov    %edx,%eax
f01014cd:	c1 e0 10             	shl    $0x10,%eax
f01014d0:	09 f0                	or     %esi,%eax
f01014d2:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01014d4:	89 d8                	mov    %ebx,%eax
f01014d6:	09 d0                	or     %edx,%eax
f01014d8:	c1 e9 02             	shr    $0x2,%ecx
f01014db:	fc                   	cld    
f01014dc:	f3 ab                	rep stos %eax,%es:(%edi)
f01014de:	eb 06                	jmp    f01014e6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01014e0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014e3:	fc                   	cld    
f01014e4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01014e6:	89 f8                	mov    %edi,%eax
f01014e8:	5b                   	pop    %ebx
f01014e9:	5e                   	pop    %esi
f01014ea:	5f                   	pop    %edi
f01014eb:	5d                   	pop    %ebp
f01014ec:	c3                   	ret    

f01014ed <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01014ed:	55                   	push   %ebp
f01014ee:	89 e5                	mov    %esp,%ebp
f01014f0:	57                   	push   %edi
f01014f1:	56                   	push   %esi
f01014f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01014f5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014f8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01014fb:	39 c6                	cmp    %eax,%esi
f01014fd:	73 35                	jae    f0101534 <memmove+0x47>
f01014ff:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0101502:	39 d0                	cmp    %edx,%eax
f0101504:	73 2e                	jae    f0101534 <memmove+0x47>
		s += n;
		d += n;
f0101506:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101509:	89 d6                	mov    %edx,%esi
f010150b:	09 fe                	or     %edi,%esi
f010150d:	f7 c6 03 00 00 00    	test   $0x3,%esi
f0101513:	75 13                	jne    f0101528 <memmove+0x3b>
f0101515:	f6 c1 03             	test   $0x3,%cl
f0101518:	75 0e                	jne    f0101528 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f010151a:	83 ef 04             	sub    $0x4,%edi
f010151d:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101520:	c1 e9 02             	shr    $0x2,%ecx
f0101523:	fd                   	std    
f0101524:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0101526:	eb 09                	jmp    f0101531 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0101528:	83 ef 01             	sub    $0x1,%edi
f010152b:	8d 72 ff             	lea    -0x1(%edx),%esi
f010152e:	fd                   	std    
f010152f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101531:	fc                   	cld    
f0101532:	eb 1d                	jmp    f0101551 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101534:	89 f2                	mov    %esi,%edx
f0101536:	09 c2                	or     %eax,%edx
f0101538:	f6 c2 03             	test   $0x3,%dl
f010153b:	75 0f                	jne    f010154c <memmove+0x5f>
f010153d:	f6 c1 03             	test   $0x3,%cl
f0101540:	75 0a                	jne    f010154c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101542:	c1 e9 02             	shr    $0x2,%ecx
f0101545:	89 c7                	mov    %eax,%edi
f0101547:	fc                   	cld    
f0101548:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010154a:	eb 05                	jmp    f0101551 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010154c:	89 c7                	mov    %eax,%edi
f010154e:	fc                   	cld    
f010154f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101551:	5e                   	pop    %esi
f0101552:	5f                   	pop    %edi
f0101553:	5d                   	pop    %ebp
f0101554:	c3                   	ret    

f0101555 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101555:	55                   	push   %ebp
f0101556:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0101558:	ff 75 10             	pushl  0x10(%ebp)
f010155b:	ff 75 0c             	pushl  0xc(%ebp)
f010155e:	ff 75 08             	pushl  0x8(%ebp)
f0101561:	e8 87 ff ff ff       	call   f01014ed <memmove>
}
f0101566:	c9                   	leave  
f0101567:	c3                   	ret    

f0101568 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0101568:	55                   	push   %ebp
f0101569:	89 e5                	mov    %esp,%ebp
f010156b:	56                   	push   %esi
f010156c:	53                   	push   %ebx
f010156d:	8b 45 08             	mov    0x8(%ebp),%eax
f0101570:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101573:	89 c6                	mov    %eax,%esi
f0101575:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101578:	eb 1a                	jmp    f0101594 <memcmp+0x2c>
		if (*s1 != *s2)
f010157a:	0f b6 08             	movzbl (%eax),%ecx
f010157d:	0f b6 1a             	movzbl (%edx),%ebx
f0101580:	38 d9                	cmp    %bl,%cl
f0101582:	74 0a                	je     f010158e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101584:	0f b6 c1             	movzbl %cl,%eax
f0101587:	0f b6 db             	movzbl %bl,%ebx
f010158a:	29 d8                	sub    %ebx,%eax
f010158c:	eb 0f                	jmp    f010159d <memcmp+0x35>
		s1++, s2++;
f010158e:	83 c0 01             	add    $0x1,%eax
f0101591:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101594:	39 f0                	cmp    %esi,%eax
f0101596:	75 e2                	jne    f010157a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0101598:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010159d:	5b                   	pop    %ebx
f010159e:	5e                   	pop    %esi
f010159f:	5d                   	pop    %ebp
f01015a0:	c3                   	ret    

f01015a1 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01015a1:	55                   	push   %ebp
f01015a2:	89 e5                	mov    %esp,%ebp
f01015a4:	53                   	push   %ebx
f01015a5:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01015a8:	89 c1                	mov    %eax,%ecx
f01015aa:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01015ad:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01015b1:	eb 0a                	jmp    f01015bd <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01015b3:	0f b6 10             	movzbl (%eax),%edx
f01015b6:	39 da                	cmp    %ebx,%edx
f01015b8:	74 07                	je     f01015c1 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01015ba:	83 c0 01             	add    $0x1,%eax
f01015bd:	39 c8                	cmp    %ecx,%eax
f01015bf:	72 f2                	jb     f01015b3 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01015c1:	5b                   	pop    %ebx
f01015c2:	5d                   	pop    %ebp
f01015c3:	c3                   	ret    

f01015c4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01015c4:	55                   	push   %ebp
f01015c5:	89 e5                	mov    %esp,%ebp
f01015c7:	57                   	push   %edi
f01015c8:	56                   	push   %esi
f01015c9:	53                   	push   %ebx
f01015ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015cd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015d0:	eb 03                	jmp    f01015d5 <strtol+0x11>
		s++;
f01015d2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015d5:	0f b6 01             	movzbl (%ecx),%eax
f01015d8:	3c 20                	cmp    $0x20,%al
f01015da:	74 f6                	je     f01015d2 <strtol+0xe>
f01015dc:	3c 09                	cmp    $0x9,%al
f01015de:	74 f2                	je     f01015d2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01015e0:	3c 2b                	cmp    $0x2b,%al
f01015e2:	75 0a                	jne    f01015ee <strtol+0x2a>
		s++;
f01015e4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01015e7:	bf 00 00 00 00       	mov    $0x0,%edi
f01015ec:	eb 11                	jmp    f01015ff <strtol+0x3b>
f01015ee:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01015f3:	3c 2d                	cmp    $0x2d,%al
f01015f5:	75 08                	jne    f01015ff <strtol+0x3b>
		s++, neg = 1;
f01015f7:	83 c1 01             	add    $0x1,%ecx
f01015fa:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01015ff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0101605:	75 15                	jne    f010161c <strtol+0x58>
f0101607:	80 39 30             	cmpb   $0x30,(%ecx)
f010160a:	75 10                	jne    f010161c <strtol+0x58>
f010160c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f0101610:	75 7c                	jne    f010168e <strtol+0xca>
		s += 2, base = 16;
f0101612:	83 c1 02             	add    $0x2,%ecx
f0101615:	bb 10 00 00 00       	mov    $0x10,%ebx
f010161a:	eb 16                	jmp    f0101632 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f010161c:	85 db                	test   %ebx,%ebx
f010161e:	75 12                	jne    f0101632 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101620:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101625:	80 39 30             	cmpb   $0x30,(%ecx)
f0101628:	75 08                	jne    f0101632 <strtol+0x6e>
		s++, base = 8;
f010162a:	83 c1 01             	add    $0x1,%ecx
f010162d:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101632:	b8 00 00 00 00       	mov    $0x0,%eax
f0101637:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010163a:	0f b6 11             	movzbl (%ecx),%edx
f010163d:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101640:	89 f3                	mov    %esi,%ebx
f0101642:	80 fb 09             	cmp    $0x9,%bl
f0101645:	77 08                	ja     f010164f <strtol+0x8b>
			dig = *s - '0';
f0101647:	0f be d2             	movsbl %dl,%edx
f010164a:	83 ea 30             	sub    $0x30,%edx
f010164d:	eb 22                	jmp    f0101671 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010164f:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101652:	89 f3                	mov    %esi,%ebx
f0101654:	80 fb 19             	cmp    $0x19,%bl
f0101657:	77 08                	ja     f0101661 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0101659:	0f be d2             	movsbl %dl,%edx
f010165c:	83 ea 57             	sub    $0x57,%edx
f010165f:	eb 10                	jmp    f0101671 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0101661:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101664:	89 f3                	mov    %esi,%ebx
f0101666:	80 fb 19             	cmp    $0x19,%bl
f0101669:	77 16                	ja     f0101681 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010166b:	0f be d2             	movsbl %dl,%edx
f010166e:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101671:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101674:	7d 0b                	jge    f0101681 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0101676:	83 c1 01             	add    $0x1,%ecx
f0101679:	0f af 45 10          	imul   0x10(%ebp),%eax
f010167d:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010167f:	eb b9                	jmp    f010163a <strtol+0x76>

	if (endptr)
f0101681:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101685:	74 0d                	je     f0101694 <strtol+0xd0>
		*endptr = (char *) s;
f0101687:	8b 75 0c             	mov    0xc(%ebp),%esi
f010168a:	89 0e                	mov    %ecx,(%esi)
f010168c:	eb 06                	jmp    f0101694 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010168e:	85 db                	test   %ebx,%ebx
f0101690:	74 98                	je     f010162a <strtol+0x66>
f0101692:	eb 9e                	jmp    f0101632 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0101694:	89 c2                	mov    %eax,%edx
f0101696:	f7 da                	neg    %edx
f0101698:	85 ff                	test   %edi,%edi
f010169a:	0f 45 c2             	cmovne %edx,%eax
}
f010169d:	5b                   	pop    %ebx
f010169e:	5e                   	pop    %esi
f010169f:	5f                   	pop    %edi
f01016a0:	5d                   	pop    %ebp
f01016a1:	c3                   	ret    
f01016a2:	66 90                	xchg   %ax,%ax
f01016a4:	66 90                	xchg   %ax,%ax
f01016a6:	66 90                	xchg   %ax,%ax
f01016a8:	66 90                	xchg   %ax,%ax
f01016aa:	66 90                	xchg   %ax,%ax
f01016ac:	66 90                	xchg   %ax,%ax
f01016ae:	66 90                	xchg   %ax,%ax

f01016b0 <__udivdi3>:
f01016b0:	55                   	push   %ebp
f01016b1:	57                   	push   %edi
f01016b2:	56                   	push   %esi
f01016b3:	53                   	push   %ebx
f01016b4:	83 ec 1c             	sub    $0x1c,%esp
f01016b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01016bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01016bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01016c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01016c7:	85 f6                	test   %esi,%esi
f01016c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01016cd:	89 ca                	mov    %ecx,%edx
f01016cf:	89 f8                	mov    %edi,%eax
f01016d1:	75 3d                	jne    f0101710 <__udivdi3+0x60>
f01016d3:	39 cf                	cmp    %ecx,%edi
f01016d5:	0f 87 c5 00 00 00    	ja     f01017a0 <__udivdi3+0xf0>
f01016db:	85 ff                	test   %edi,%edi
f01016dd:	89 fd                	mov    %edi,%ebp
f01016df:	75 0b                	jne    f01016ec <__udivdi3+0x3c>
f01016e1:	b8 01 00 00 00       	mov    $0x1,%eax
f01016e6:	31 d2                	xor    %edx,%edx
f01016e8:	f7 f7                	div    %edi
f01016ea:	89 c5                	mov    %eax,%ebp
f01016ec:	89 c8                	mov    %ecx,%eax
f01016ee:	31 d2                	xor    %edx,%edx
f01016f0:	f7 f5                	div    %ebp
f01016f2:	89 c1                	mov    %eax,%ecx
f01016f4:	89 d8                	mov    %ebx,%eax
f01016f6:	89 cf                	mov    %ecx,%edi
f01016f8:	f7 f5                	div    %ebp
f01016fa:	89 c3                	mov    %eax,%ebx
f01016fc:	89 d8                	mov    %ebx,%eax
f01016fe:	89 fa                	mov    %edi,%edx
f0101700:	83 c4 1c             	add    $0x1c,%esp
f0101703:	5b                   	pop    %ebx
f0101704:	5e                   	pop    %esi
f0101705:	5f                   	pop    %edi
f0101706:	5d                   	pop    %ebp
f0101707:	c3                   	ret    
f0101708:	90                   	nop
f0101709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101710:	39 ce                	cmp    %ecx,%esi
f0101712:	77 74                	ja     f0101788 <__udivdi3+0xd8>
f0101714:	0f bd fe             	bsr    %esi,%edi
f0101717:	83 f7 1f             	xor    $0x1f,%edi
f010171a:	0f 84 98 00 00 00    	je     f01017b8 <__udivdi3+0x108>
f0101720:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101725:	89 f9                	mov    %edi,%ecx
f0101727:	89 c5                	mov    %eax,%ebp
f0101729:	29 fb                	sub    %edi,%ebx
f010172b:	d3 e6                	shl    %cl,%esi
f010172d:	89 d9                	mov    %ebx,%ecx
f010172f:	d3 ed                	shr    %cl,%ebp
f0101731:	89 f9                	mov    %edi,%ecx
f0101733:	d3 e0                	shl    %cl,%eax
f0101735:	09 ee                	or     %ebp,%esi
f0101737:	89 d9                	mov    %ebx,%ecx
f0101739:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010173d:	89 d5                	mov    %edx,%ebp
f010173f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101743:	d3 ed                	shr    %cl,%ebp
f0101745:	89 f9                	mov    %edi,%ecx
f0101747:	d3 e2                	shl    %cl,%edx
f0101749:	89 d9                	mov    %ebx,%ecx
f010174b:	d3 e8                	shr    %cl,%eax
f010174d:	09 c2                	or     %eax,%edx
f010174f:	89 d0                	mov    %edx,%eax
f0101751:	89 ea                	mov    %ebp,%edx
f0101753:	f7 f6                	div    %esi
f0101755:	89 d5                	mov    %edx,%ebp
f0101757:	89 c3                	mov    %eax,%ebx
f0101759:	f7 64 24 0c          	mull   0xc(%esp)
f010175d:	39 d5                	cmp    %edx,%ebp
f010175f:	72 10                	jb     f0101771 <__udivdi3+0xc1>
f0101761:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101765:	89 f9                	mov    %edi,%ecx
f0101767:	d3 e6                	shl    %cl,%esi
f0101769:	39 c6                	cmp    %eax,%esi
f010176b:	73 07                	jae    f0101774 <__udivdi3+0xc4>
f010176d:	39 d5                	cmp    %edx,%ebp
f010176f:	75 03                	jne    f0101774 <__udivdi3+0xc4>
f0101771:	83 eb 01             	sub    $0x1,%ebx
f0101774:	31 ff                	xor    %edi,%edi
f0101776:	89 d8                	mov    %ebx,%eax
f0101778:	89 fa                	mov    %edi,%edx
f010177a:	83 c4 1c             	add    $0x1c,%esp
f010177d:	5b                   	pop    %ebx
f010177e:	5e                   	pop    %esi
f010177f:	5f                   	pop    %edi
f0101780:	5d                   	pop    %ebp
f0101781:	c3                   	ret    
f0101782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101788:	31 ff                	xor    %edi,%edi
f010178a:	31 db                	xor    %ebx,%ebx
f010178c:	89 d8                	mov    %ebx,%eax
f010178e:	89 fa                	mov    %edi,%edx
f0101790:	83 c4 1c             	add    $0x1c,%esp
f0101793:	5b                   	pop    %ebx
f0101794:	5e                   	pop    %esi
f0101795:	5f                   	pop    %edi
f0101796:	5d                   	pop    %ebp
f0101797:	c3                   	ret    
f0101798:	90                   	nop
f0101799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01017a0:	89 d8                	mov    %ebx,%eax
f01017a2:	f7 f7                	div    %edi
f01017a4:	31 ff                	xor    %edi,%edi
f01017a6:	89 c3                	mov    %eax,%ebx
f01017a8:	89 d8                	mov    %ebx,%eax
f01017aa:	89 fa                	mov    %edi,%edx
f01017ac:	83 c4 1c             	add    $0x1c,%esp
f01017af:	5b                   	pop    %ebx
f01017b0:	5e                   	pop    %esi
f01017b1:	5f                   	pop    %edi
f01017b2:	5d                   	pop    %ebp
f01017b3:	c3                   	ret    
f01017b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01017b8:	39 ce                	cmp    %ecx,%esi
f01017ba:	72 0c                	jb     f01017c8 <__udivdi3+0x118>
f01017bc:	31 db                	xor    %ebx,%ebx
f01017be:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01017c2:	0f 87 34 ff ff ff    	ja     f01016fc <__udivdi3+0x4c>
f01017c8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01017cd:	e9 2a ff ff ff       	jmp    f01016fc <__udivdi3+0x4c>
f01017d2:	66 90                	xchg   %ax,%ax
f01017d4:	66 90                	xchg   %ax,%ax
f01017d6:	66 90                	xchg   %ax,%ax
f01017d8:	66 90                	xchg   %ax,%ax
f01017da:	66 90                	xchg   %ax,%ax
f01017dc:	66 90                	xchg   %ax,%ax
f01017de:	66 90                	xchg   %ax,%ax

f01017e0 <__umoddi3>:
f01017e0:	55                   	push   %ebp
f01017e1:	57                   	push   %edi
f01017e2:	56                   	push   %esi
f01017e3:	53                   	push   %ebx
f01017e4:	83 ec 1c             	sub    $0x1c,%esp
f01017e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01017eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01017ef:	8b 74 24 34          	mov    0x34(%esp),%esi
f01017f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017f7:	85 d2                	test   %edx,%edx
f01017f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01017fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0101801:	89 f3                	mov    %esi,%ebx
f0101803:	89 3c 24             	mov    %edi,(%esp)
f0101806:	89 74 24 04          	mov    %esi,0x4(%esp)
f010180a:	75 1c                	jne    f0101828 <__umoddi3+0x48>
f010180c:	39 f7                	cmp    %esi,%edi
f010180e:	76 50                	jbe    f0101860 <__umoddi3+0x80>
f0101810:	89 c8                	mov    %ecx,%eax
f0101812:	89 f2                	mov    %esi,%edx
f0101814:	f7 f7                	div    %edi
f0101816:	89 d0                	mov    %edx,%eax
f0101818:	31 d2                	xor    %edx,%edx
f010181a:	83 c4 1c             	add    $0x1c,%esp
f010181d:	5b                   	pop    %ebx
f010181e:	5e                   	pop    %esi
f010181f:	5f                   	pop    %edi
f0101820:	5d                   	pop    %ebp
f0101821:	c3                   	ret    
f0101822:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101828:	39 f2                	cmp    %esi,%edx
f010182a:	89 d0                	mov    %edx,%eax
f010182c:	77 52                	ja     f0101880 <__umoddi3+0xa0>
f010182e:	0f bd ea             	bsr    %edx,%ebp
f0101831:	83 f5 1f             	xor    $0x1f,%ebp
f0101834:	75 5a                	jne    f0101890 <__umoddi3+0xb0>
f0101836:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010183a:	0f 82 e0 00 00 00    	jb     f0101920 <__umoddi3+0x140>
f0101840:	39 0c 24             	cmp    %ecx,(%esp)
f0101843:	0f 86 d7 00 00 00    	jbe    f0101920 <__umoddi3+0x140>
f0101849:	8b 44 24 08          	mov    0x8(%esp),%eax
f010184d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101851:	83 c4 1c             	add    $0x1c,%esp
f0101854:	5b                   	pop    %ebx
f0101855:	5e                   	pop    %esi
f0101856:	5f                   	pop    %edi
f0101857:	5d                   	pop    %ebp
f0101858:	c3                   	ret    
f0101859:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101860:	85 ff                	test   %edi,%edi
f0101862:	89 fd                	mov    %edi,%ebp
f0101864:	75 0b                	jne    f0101871 <__umoddi3+0x91>
f0101866:	b8 01 00 00 00       	mov    $0x1,%eax
f010186b:	31 d2                	xor    %edx,%edx
f010186d:	f7 f7                	div    %edi
f010186f:	89 c5                	mov    %eax,%ebp
f0101871:	89 f0                	mov    %esi,%eax
f0101873:	31 d2                	xor    %edx,%edx
f0101875:	f7 f5                	div    %ebp
f0101877:	89 c8                	mov    %ecx,%eax
f0101879:	f7 f5                	div    %ebp
f010187b:	89 d0                	mov    %edx,%eax
f010187d:	eb 99                	jmp    f0101818 <__umoddi3+0x38>
f010187f:	90                   	nop
f0101880:	89 c8                	mov    %ecx,%eax
f0101882:	89 f2                	mov    %esi,%edx
f0101884:	83 c4 1c             	add    $0x1c,%esp
f0101887:	5b                   	pop    %ebx
f0101888:	5e                   	pop    %esi
f0101889:	5f                   	pop    %edi
f010188a:	5d                   	pop    %ebp
f010188b:	c3                   	ret    
f010188c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101890:	8b 34 24             	mov    (%esp),%esi
f0101893:	bf 20 00 00 00       	mov    $0x20,%edi
f0101898:	89 e9                	mov    %ebp,%ecx
f010189a:	29 ef                	sub    %ebp,%edi
f010189c:	d3 e0                	shl    %cl,%eax
f010189e:	89 f9                	mov    %edi,%ecx
f01018a0:	89 f2                	mov    %esi,%edx
f01018a2:	d3 ea                	shr    %cl,%edx
f01018a4:	89 e9                	mov    %ebp,%ecx
f01018a6:	09 c2                	or     %eax,%edx
f01018a8:	89 d8                	mov    %ebx,%eax
f01018aa:	89 14 24             	mov    %edx,(%esp)
f01018ad:	89 f2                	mov    %esi,%edx
f01018af:	d3 e2                	shl    %cl,%edx
f01018b1:	89 f9                	mov    %edi,%ecx
f01018b3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01018b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01018bb:	d3 e8                	shr    %cl,%eax
f01018bd:	89 e9                	mov    %ebp,%ecx
f01018bf:	89 c6                	mov    %eax,%esi
f01018c1:	d3 e3                	shl    %cl,%ebx
f01018c3:	89 f9                	mov    %edi,%ecx
f01018c5:	89 d0                	mov    %edx,%eax
f01018c7:	d3 e8                	shr    %cl,%eax
f01018c9:	89 e9                	mov    %ebp,%ecx
f01018cb:	09 d8                	or     %ebx,%eax
f01018cd:	89 d3                	mov    %edx,%ebx
f01018cf:	89 f2                	mov    %esi,%edx
f01018d1:	f7 34 24             	divl   (%esp)
f01018d4:	89 d6                	mov    %edx,%esi
f01018d6:	d3 e3                	shl    %cl,%ebx
f01018d8:	f7 64 24 04          	mull   0x4(%esp)
f01018dc:	39 d6                	cmp    %edx,%esi
f01018de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01018e2:	89 d1                	mov    %edx,%ecx
f01018e4:	89 c3                	mov    %eax,%ebx
f01018e6:	72 08                	jb     f01018f0 <__umoddi3+0x110>
f01018e8:	75 11                	jne    f01018fb <__umoddi3+0x11b>
f01018ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01018ee:	73 0b                	jae    f01018fb <__umoddi3+0x11b>
f01018f0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01018f4:	1b 14 24             	sbb    (%esp),%edx
f01018f7:	89 d1                	mov    %edx,%ecx
f01018f9:	89 c3                	mov    %eax,%ebx
f01018fb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01018ff:	29 da                	sub    %ebx,%edx
f0101901:	19 ce                	sbb    %ecx,%esi
f0101903:	89 f9                	mov    %edi,%ecx
f0101905:	89 f0                	mov    %esi,%eax
f0101907:	d3 e0                	shl    %cl,%eax
f0101909:	89 e9                	mov    %ebp,%ecx
f010190b:	d3 ea                	shr    %cl,%edx
f010190d:	89 e9                	mov    %ebp,%ecx
f010190f:	d3 ee                	shr    %cl,%esi
f0101911:	09 d0                	or     %edx,%eax
f0101913:	89 f2                	mov    %esi,%edx
f0101915:	83 c4 1c             	add    $0x1c,%esp
f0101918:	5b                   	pop    %ebx
f0101919:	5e                   	pop    %esi
f010191a:	5f                   	pop    %edi
f010191b:	5d                   	pop    %ebp
f010191c:	c3                   	ret    
f010191d:	8d 76 00             	lea    0x0(%esi),%esi
f0101920:	29 f9                	sub    %edi,%ecx
f0101922:	19 d6                	sbb    %edx,%esi
f0101924:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101928:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010192c:	e9 18 ff ff ff       	jmp    f0101849 <__umoddi3+0x69>
