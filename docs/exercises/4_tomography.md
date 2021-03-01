# 4. Tomografía 2D de ondas superficiales

## 4.1. Visualize dispersion measurements. Preparation for tomography

Working directory:

    $ cd
    $ plot_aftan_disp.sh prefix

Look at the contents of the dsp and phv files

Devise a strategy to convert station pair measurements into files that contain dispersion measurements for a given period (with different files for group and phase velocities and Love and Rayleigh waves: RC, RU, LC, LU).

Look at the contents of ~/scripts/get_mftdisp.sh. Run script:

    $ get_mftdisp.sh

Check number of measurements for each file:

    $ wc -l *.dat

Look at the contents of the dat files.

## 4.2. Surface wave tomography (2D)

Working directory:

    $ cd
    $ cd exercises/tomography/RC020.0

Look at contents of tomo.sh and run it:

    $ tomo.sh

Plot results:

    $ plot_map.sh RC_1200_250_10_20.0.1
    $ gv RC_1200_250_10_20.0.ps

Change values of alpha and sigma and see differences in results.


