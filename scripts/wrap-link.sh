#! /bin/sh
# Split link-edit into two stage for linking static applications with
# Xenomai user-space posix skin.

set -e

usage() {
    cat <<EOF
$progname [options] command-line

Split command-line in two parts for linking static applications with
Xenomai user-space posix skin in two stages.

Options:
-q be quiet
-v be verbose (print each command before running it)

Example:
$progname -v gcc -o foo foo.o -Wl,@/usr/xenomai/lib/posix.wrappers -L/usr/xenomai/lib -lpthread_rt -lpthread -lrt
will print and run:
+ gcc -o foo.tmp -Wl,-r -nostdlib tmp foo.o -Wl,@/usr/xenomai/lib/posix.wrappers -L/usr/xenomai/lib
+ gcc -o foo foo.tmp -lpthread_rt -lpthread -lrt
+ rm foo.tmp
EOF
}

add_linker_flag() {
    if $next_is_wrapped_symbol; then
	stage1_args="$stage1_args -Wl,--wrap $@"
	next_is_wrapped_symbol=false
    else
	stage1_args="$stage1_args $@"
	stage2_args="$stage2_args $@"
    fi
}

add_linker_obj() {
    if $stage2; then
	stage2_args="$stage2_args $@"
    else
	stage1_args="$stage1_args $@"
    fi
}

if test -n "$V" && test $V -gt 0; then
    verbose=:
else
    verbose=false
fi
progname=$0

if test $# -eq 0; then
    usage
    exit 0
fi

while test $# -gt 0; do
    arg="$1"
    shift
    case "$arg" in
	"")
	    usage
	    exit 0
	    ;;

	-v) 
	    verbose=:
	    ;;

	-q) 
	    verbose=false
	    ;;

	-*)
	    cc="$cc $arg"
	    ;;

	*gcc*|*g++*)
	    cc="$cc $arg"
	    break
	    ;;

	*ld)
	    usage
	    /bin/echo -e "\nlinker must be gcc or g++, not ld"
	    exit 1
	    ;;

	*)
	    cc="$cc $arg"
	    ;;
    esac
done

next_is_wrapped_symbol=false
stage1_args=""
stage2_args=""
stage2=false
while test $# -gt 0; do
    arg="$1"
    shift
    case "$arg" in
	*pthread_rt*|-lpthread)
	    stage2_args="$stage2_args $arg"
	    stage2=:
	    ;;

	-Xlinker)
	    arg="$1"
	    shift
	    case "$arg" in
		--wrap)
		    next_is_wrapped_symbol=:
		    ;;
		@*posix.wrappers)
		    stage1_args="$stage1_args -Xlinker $arg"
		    ;;

		*) 
		    add_linker_flag -Xlinker "$arg"
		    ;;
	    esac
	    ;;

	-Wl,--wrap)
	    next_is_wrapped_symbol=:
	    ;;

	-Wl,@*posix.wrappers|-Wl,--wrap,*)
	    stage1_args="$stage1_args $arg"
	    ;;

	-Wl,*)
	    add_linker_flag "$arg"
	    ;;

	-o)
	    output="$1"
	    shift
	    ;;

	-o*)
	    output=`expr $arg : '-o\(.*\)'`
	    ;;
	
	-l) 
	    arg="$1"
	    shift
	    add_linker_obj -l $arg
	    ;;

	-l*) #a library
	    add_linker_obj $arg
	    ;;

	*.so)
	    stage2_args="$stage2_args $arg"
	    ;;

	*) 
	    if test -e "$arg"; then
		add_linker_obj $arg
	    else
		stage1_args="$stage1_args $arg"
		stage2_args="$stage2_args $arg"
	    fi
	   ;;
    esac
done

$verbose && set -x
tmpobj="$output.wl$$"
$cc -o "$tmpobj" -Wl,-Ur -nostdlib $stage1_args
$cc -o "$output" "$tmpobj" $stage2_args
rm -f $tmpobj