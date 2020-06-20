val g_filename = "result.ppm"
val g_dimensions = (320*4, 180*4)

val g_samples = 64
val g_bounces = 4
val g_dropoff = 32


type v3 = real * real * real;

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


fun v3r s = (s,s,s);
fun v3i s = v3r (Real.fromInt s);

fun v3m f (x,y,z) = (f x, f y, f z);
fun v3op f (x,y,z) (a,b,c) = (f x a, f y b, f z c);

fun v3neg ((x,y,z) : v3) : v3 = (~x, ~y, ~z);

fun v3dot ((x,y,z) : v3) ((a,b,c) : v3) : real = x*a + y*b + z*c;
fun v3len (v : v3) = Math.sqrt(v3dot v v);
fun v3norm (v : v3) = v3divvs v (v3len v);


fun range s e =
	if s < e
	then s :: range (s+1) e
	else nil;


fun v3hash ((x,y,z) : v3) : v3 =
	let
		fun mod1 x = x - (Real.realFloor x)
		fun helper a b = mod1 (1000.0 * Math.sin(a) + b + 0.5)
	in
		v3op helper (x,y,z) (z,x,y)
	end;


val v3rand =
	let
		val temp_h = v3hash o v3hash
		val temp_h = temp_h o temp_h
		val temp_h = temp_h o temp_h
		val temp_h = temp_h o temp_h

		val state = ref (temp_h (1.0, 2.0, 3.0))
	in
		(fn () => (state := v3hash (!state); !state : v3))
	end;


fun hemi (n : v3) ((rx,ry,_) : v3) : v3 =
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
		val oc = v3neg ro
		val b = v3dot rd oc
		val c = v3dot oc oc - 1.0
		val h = b * b - c
	in
		if h < 0.0
		then (t, sp, sn, e)
		else let
			val nt = b + (Math.sqrt h)
			val nsp = v3addvv ro (v3mulvs rd nt)
			val nsn = v3norm nsp
		in
			if nt > 0.0 andalso nt < t
			then (nt, nsn, nsn, emit)
			else (t, sp, sn, e)
		end
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
		val hit = (10000.0, v3i 0, v3i 0, v3i 0)
		val hit = sphere hit (0.0, 0.0, 0.0) ro rd
		val hit = plane  hit (0.0, 0.0, 0.0) ro rd ( 0.0, ~1.0,  0.0) 3.0
		val hit = plane  hit (0.0, 0.0, 0.0) ro rd ( 0.0,  1.0,  0.0) 1.0
		val hit = plane  hit (1.0, 0.0, 0.5) ro rd (~1.0,  0.0,  0.0) 3.0
		val hit = plane  hit (0.0, 1.0, 0.5) ro rd ( 1.0,  0.0,  0.0) 3.0
		val hit = plane  hit (0.0, 0.0, 0.0) ro rd ( 0.0,  0.0,  1.0) 8.0
		val hit = plane  hit (0.0, 0.0, 0.0) ro rd ( 0.0,  0.0, ~1.0) 2.0
	in
		hit
	end;


fun render ro rd n 0 = (v3i 0)
  | render ro rd n l =
	let
		val rng = v3rand ()

		val (t,sp,sn,emit) = tracer ro rd

		val ro = v3addvv sp (v3mulvs sn 0.001)
		val rd = hemi sn rng

		val nn = Int.max (n div g_dropoff, 1)
		val nl = l-1

		val samples = map (fn _ => render ro rd nn nl) (range 0 n)

		val acc = foldl (fn (x, y) => v3addvv x y) (v3i 0) samples
		val acc = v3divvs acc (Math.pi * Real.fromInt n)
	in
		v3addvv emit acc
	end;


fun pixel x y w h =
	let
		val rdx = Real.fromInt (2 * x - w)
		val rdy = Real.fromInt (h - 2 * y)
		val rdz = Real.fromInt (2 * h)

		val rd = v3norm (rdx, rdy, rdz)
		val ro = (0.0, 1.0, ~6.2)

		val emit = render ro rd g_samples g_bounces

		val col = v3mulvs emit 12.0
		val col = v3m (fn c => Real.max(0.0, Real.min(1.0, c))) col
		val col = v3m (fn c => Math.pow(c, 1.0 / 2.2)) col

		val (r,g,b) = v3m (fn c => Real.round (255.0 * c)) col
	in
		implode (chr(r)::chr(g)::chr(b)::nil)
	end;


fun status (w,h,t) x y =
	let
		val iid = y * w + x
		val rid = Real.fromInt iid

		val rprog = rid / Real.fromInt (w*h)
		val sprog = Real.fmt (StringCvt.FIX (SOME 1)) (100.0 * rprog)
		val iprog = Real.round (20.0 * rprog)

		val sbar = range 0 20
		val sbar = map (fn x => if (x < iprog) then #"#" else #".") sbar
		val sbar = implode sbar

		val ttime = #usr(Timer.checkCPUTimer(t))
		val rtime = Time.toReal ttime
		val stime = Real.fmt (StringCvt.FIX (SOME 3)) rtime

		val rrate = rid / (rtime * 1000.0)
		val srate = Real.fmt (StringCvt.FIX (SOME 3)) rrate

		val rtotal = rtime / rprog
		val rleft = rtotal - rtime
		val sleft = Real.fmt (StringCvt.FIX (SOME 3)) rleft

		val text = "\rRendering: [" ^ sbar ^ "] " ^ sprog ^ "%, " ^ srate ^ "Kp/s, elapsed: " ^ stime ^ "s, left: " ^ sleft ^ "s "
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
