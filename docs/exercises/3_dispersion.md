# 3. Calcular la dispersión de un modelo de velocidad

Working directory:

    $ cd
    $ cd exercises/dispersion
    $ dispersion.sh ak135.mod
    $ gv L.ak135.mod.ps
    $ gv R.ak135.mod.ps

Test other models:

- Split first layer of 5.0 km in two of 2.5 km. Assign to first layer the properties of water (Vp = 1.5 km/s)
- Same but assign to first layer the properties of sediments. Use e.g. Vp/Vs = 1.8. Check influence of density
- Vary Moho depth from 25 to 70 km and see effect on dispersion curves

Hint. Copy ak135.mod with another name, and edit new file:

    $ cp ak135.mod ocean.mod			# edit ocean.mod
    $ cp ak135.mod sediments.mod
    $ cp ak135.mod moho25.mod
    $ …
    $ cp ak135.mod moho70.mod

Compare different dispersion curves.

