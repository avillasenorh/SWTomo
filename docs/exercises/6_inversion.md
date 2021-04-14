# 6. Inversión 1D

En este ejercicio invertiremos curvas de dispersión para
obtener un modelo de velocidad 1-D de la onda S.

En primer lugar ir al directorio de trabajo:

    $ cd
    $ cd exercises/inversion

Check contents of `surf_inv.sh` and run it:

    $ surf_inv.sh test.disp ak135.mod

Visualize results:

    $ gv DATAFIT.eps
    $ gv MODEL.eps

Ouptut file is in `model.out`.

Change dispersion file, initial model, and parameters in `surf_inv.sh`.

