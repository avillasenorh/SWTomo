# 2. Procesado de correlaciones de ruido ambiente

Working directory:

    $ cd 
    $ cd exercises/correlations

Pick group and phase velocities manually (only vertical components available):

    $ do_mft -G -IG *_S

Plot results:

    $ plot_aftan_disp.sh COR_ARAC.IG._MVO.PM. (prefix of dsp and phv files)

Verify that phase velocities are generally larger that group velocities. Also
verify that phase velocity curves usually do not have minima, while group
velocities often have.

Pick group and phase velocities automatically (`FTAN`)

Prepare a 1-line parameter file called aftan.par as follows:

    -1 1.0 5.0 2 100 20 1 0.5 0.2 2 COR_ARAC.IG._MVO.PM._ZZ_S

Explain meaning of parameters.

Verify that the reference phase velocity dispersion file `avg_phvel.dat` is present. Look at its contents.

Run automatic FTAN code:

    $ aftani_c_pgl aftan.par

Look at the output files. Plot them with:

    $ plot_aftan_disp.sh COR_ARAC.IG._MVO.PM.

Devise a method to process all the cross correlations in the current directory.

