# 1. Medidas de dispersión de ondas superficiales de terremotos

## 1.1 Observation of surface waves and SAC basics

Go to working directory `~/exercises/earthquake`, launch `SAC` and run the following commands:

    $ cd 
    $ cd exercises/earthquake			# use tab completion
    $ sac
    SAC > r GUD*
    SAC > qdp off
    SAC > p1
    SAC > rmean
    SAC > taper
    SAC > lowpass co .1 n 3 p 2		# search meaning in SAC manual
    SAC > ppk bell off				# use “x” and “o” to zoom in and out
    SAC > ...
    SAC> r ESBBESBHZ ESBBESBHR
    SAC> rmean
    SAC> taper
    SAC> lp					# commands remember parameters
    SAC> p1
    SAC> xlim 130 170
    SAC> p1
    SAC> ppm					# plots particle motion
    SAC > q
    $

Use cursor to check that Rayleigh wave is elliptically polarized.
Use ppm command to see particle motion in ZR plane.

[SAC manual](https://ds.iris.edu/files/sac-manual/)

Repeat for other stations.

Other commands to check: `lh`, `bp`, `fft`, `psp`, `sss`, `sort`.


## 2. Measure group velocity from earthquakes

Working directory:

    $ cd 
    $ cd exercises/earthquake

First try simple approach: filtering and envelope:

    $ sac
    SAC> r GUD*
    GUDESHHR GUDESHHT GUDESHHZ
    SAC> qdp off
    SAC> p1
    SAC> xlim 100 300
    SAC> p1
    SAC> rmean
    SAC> taper
    SAC> bp co .09 .11 n 3 p 2
    SAC> p1
    SAC> envelope
    SAC> p1
    SAC> ppk bell off

Select peak of envelope. Calculate group velocity \(U\) by simply doing: \(U = \Delta / t\)
where \(\Delta\) is the epicentral distance, and \(t\) is arrival time.

Repeat for other periods. Note the artifacts when the filter is too narrow.

Then try with `do_mft`:

    $ do_mft -G GUD* 

Compare results obtained manually with the output files `*.dsp`

Process the entire event:

    $ do_mft -G *T
    $ do_mft -G *Z
    $ do_mft -G *R

Check that the measurements on the vertical and radial component are identical.

Plot results

__Need file to plot dsp files.__


