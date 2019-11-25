val g_filename = "result.ppm"
val g_dimensions = (320, 180)

val g_samples = 8
val g_bounces = 4
val g_dropoff = 2


type v3 = real * real * real;

fun v3c s = (s,s,s);
fun v3m f (x,y,z) = (f x, f y, f z);
fun v3op f (x,y,z) (a,b,c) = (f x a, f y b, f z c);

fun v3neg (x,y,z) : v3 = (~x, ~y, ~z);

fun v3addvv (x,y,z) (a,b,c) : v3 = (x+a, y+b, z+c);
fun v3addvs (x,y,z)    s    : v3 = (x+s, y+s, z+s);
fun v3addsv    s    (x,y,z) : v3 = (s+x, s+y, s+z);

fun v3subvv (x,y,z) (a,b,c) : v3 = (x-a, y-b, z-c);
fun v3subvs (x,y,z)    s    : v3 = (x-s, y-s, z-s);
fun v3subsv    s    (x,y,z) : v3 = (s-x, s-y, s-z);

fun v3mulvv (x,y,z) (a,b,c) : v3 = (x*a, y*b, z*c);
fun v3mulvs (x,y,z)    s    : v3 = (x*s, y*s, z*s);
fun v3mulsv    s    (x,y,z) : v3 = (s*x, s*y, s*z);

fun v3divvv (x,y,z) (a,b,c) : v3 = (x/a, y/b, z/c);
fun v3divvs (x,y,z)    s    : v3 = (x/s, y/s, z/s);
fun v3divsv    s    (x,y,z) : v3 = (s/x, s/y, s/z);

fun v3dot (x,y,z) (a,b,c) : real = x*a + y*b + z*c;
fun v3len v = Math.sqrt(v3dot v v);
fun v3norm v = v3divvs v (v3len v);


fun range s e =
	if s < e
	then s :: range (s+1) e
	else nil;


fun v3hash (x,y,z) : v3 =
	let
		fun mod1 x = x - (Real.realFloor x)
		fun helper a b = mod1 (1000.0 * Math.sin(a) + b + 0.5)
	in
		v3op helper (x,y,z) (z,x,y)
	end;


fun hemi n (rx,ry,_) =
	let
		val a = 2.0 * rx - 1.0;
		val b = 2.0 * ry * Math.pi;
		val c = Math.sqrt(1.0 - a*a)
		val r = (c * Math.cos (b), a, c * Math.sin (b))
	in
		if (v3dot n r) > 0.0 then r else v3neg(r)
	end;


fun sphere (t,sp,sn,e) emit ro rd =
	let
		fun h d q 0 = (d, q)
		  | h d _ i =
			let
				val p = v3addvv ro (v3mulvs rd d)
				val m = v3len(p) - 1.0
			in
				if m > 0.001
				then h (d+m) p (i-1)
				else h (d+m) p 0
			end

		val (nt,nsp) = h 0.0 (v3c 0.0) 16
		val nsn = (v3norm nsp)
	in
		if nt < t
		then (nt, nsp, nsn, emit)
		else (t, sp, sn, e)
	end;


fun plane (t,sp,sn,e) emit ro rd n d =
	let
		val nt = ~((v3dot ro n) + d) / (v3dot n rd)
		val nt = if nt < 0.0 then 10000.0 else nt
		val nsp = v3addvv ro (v3mulvs rd nt)
		val nsn = n
	in
		if nt < t
		then (nt, nsp, nsn, emit)
		else (t, sp, sn, e)
	end;


fun tracer ro rd =
	let
		val hit = (10000.0, v3c 0.0, v3c 0.0, v3c 0.0)
		val hit = sphere hit (0.0, 0.0, 0.0) ro rd
		val hit = plane  hit (0.0, 0.0, 0.0) ro rd ( 0.0,  1.0,  0.0) 1.0
		val hit = plane  hit (0.0, 0.0, 0.0) ro rd ( 0.0, ~1.0,  0.0) 3.0
		val hit = plane  hit (1.0, 0.0, 0.5) ro rd (~1.0,  0.0,  0.0) 3.0
		val hit = plane  hit (0.0, 1.0, 0.5) ro rd ( 1.0,  0.0,  0.0) 3.0
		val hit = plane  hit (0.0, 0.0, 0.0) ro rd ( 0.0,  0.0,  1.0) 8.0
		val hit = plane  hit (0.0, 0.0, 0.0) ro rd ( 0.0,  0.0, ~1.0) 2.0
	in
		hit
	end;


fun render rng ro rd n 0 = (v3c 0.0)
  | render rng ro rd n l =
	let
		val rng = v3hash rng
		val (t,sp,sn,emit) = tracer ro rd

		val nrd = hemi sn rng
		val nro = v3addvv sp (v3mulvs sn 0.001)

		val nn = Int.max (n div g_dropoff, 1)
		val nl = l - 1

		fun accum rngk a 0 = a
		  | accum rngk a k = accum (v3addvs rngk 4.0) (v3addvv a (render rngk nro nrd nn nl)) (k-1)

		val cum = accum rng (v3c 0.0) n
		val cum = v3divvs cum (Math.pi * Real.fromInt n)
	in
		v3addvv emit cum
	end;


fun pixel x y w h =
	let
		val seed = v3m (fn x => Real.fromInt x) (x, y, 1)
		val seed = v3hash (v3hash (v3hash (v3hash seed)))

		val rdx = Real.fromInt (2 * x - w)
		val rdy = Real.fromInt (h - 2 * y)
		val rdz = Real.fromInt (2 * h)

		val rd = v3norm (rdx, rdy, rdz)
		val ro = (0.0, 1.0, ~6.2)

		val emit = render seed ro rd g_samples g_bounces

		val col = v3mulvs emit 12.0
		val col = v3m (fn c => Real.max(0.0, Real.min(1.0, c))) col
		val col = v3m (fn c => Math.pow(c, 1.0 / 2.2)) col

		val (r,g,b) = v3m (fn c => Real.round (255.0 * c)) col
	in
		implode (chr(r)::chr(g)::chr(b)::nil)
	end;


fun status (w,h,t) x y =
	let
		val rprog = Real.fromInt (y * w + x) / Real.fromInt (w*h)
		val iprog = Real.round (100.0 * rprog)
		val sprog = Int.toString iprog

		val sbar = range 0 20
		val sbar = map (fn x => if (5 * x < iprog) then #"#" else #" ") sbar
		val sbar = implode sbar

		val ttime = #usr(Timer.checkCPUTimer(t))
		val rtime = Time.toReal ttime
		val stime = Real.fmt (StringCvt.FIX (SOME 3)) rtime

		val rtotal = rtime / rprog
		val rleft = rtotal - rtime
		val sleft = Real.fmt (StringCvt.FIX (SOME 3)) rleft

		val text = "\rRendering: [" ^ sbar ^ "] " ^ sprog ^ "% - elapsed: " ^ stime ^ " - left: " ^ sleft ^ " "
	in
		print (text)
	end


fun writeGrid file width height =
	let
		val start = (width, height, Timer.startCPUTimer())
		fun cell x y = (status start x y; pixel x y width height)

		val cols = range 0 width
		fun rows y = if y < height
			then (TextIO.output(file, String.concat(map (fn x => cell x y) cols)); rows (y+1))
			else (print "\n")
	in
		rows 0
	end;


fun writePPM name (width, height) =
	let
		val file = TextIO.openOut name
		val dimensions = (Int.toString(width) ^ " " ^ Int.toString(height))
		val header = ("P6\n" ^ dimensions ^ "\n255\n")
	in
		(TextIO.output(file, header); writeGrid file width height; TextIO.closeOut file)
	end;


writePPM g_filename g_dimensions;
