int main (string[] args) {
    Solpos.Posdata pd = {};
    long retval;

    pd.init ();
    
    pd.longitude = -84.43f;
    pd.latitude = 33.65f;
    pd.timezone = -5.0f;
    pd.year = 1999;
    pd.daynum = 203;
    pd.hour = 9;
    pd.minute = 45;
    pd.second = 37;
    pd.temp = 27.0f;
    pd.press = 1006.0f;
    pd.tilt = pd.latitude;
    pd.aspect = 135.0f;
    
    stdout.printf ( "\n" );
    stdout.printf ( "***** TEST S_solpos: *****\n" );
    stdout.printf ( "\n" );

    retval = pd.solpos ();
    pd.decode (retval);

    stdout.printf ( "Note that your final decimal place values may vary\n" );
    stdout.printf ( "based on your computer's floating-point storage and your\n" );
    stdout.printf ( "compiler's mathematical algorithms.  If you agree with\n" );
    stdout.printf ( "NREL's values for at least 5 significant digits, assume it works.\n\n" );

    stdout.printf ( "Note that S_solpos has returned the day and month for the\n");
    stdout.printf ( "input daynum.  When configured to do so, S_solpos will reverse\n");
    stdout.printf ( "this input/output relationship, accepting month and day as\n");
    stdout.printf ( "input and returning the day-of-year in the daynum variable.\n");
    stdout.printf ("\n" );
    stdout.printf ( "NREL    -> 1999.07.22, daynum 203, retval 0, amass 1.335752, ampress 1.326522\n" );
    stdout.printf ( "SOLTEST -> %d.%0.2d.%0.2d, daynum %d, retval %ld, amass %f, ampress %f\n",
            pd.year, pd.month, pd.day, pd.daynum,
            retval, pd.amass, pd.ampress );
    stdout.printf ( "NREL    -> azim 97.032875, cosinc 0.912569, elevref 48.409931\n" );
    stdout.printf ( "SOLTEST -> azim %f, cosinc %f, elevref %f\n",
            pd.azim,    pd.cosinc,    pd.elevref );
    stdout.printf ( "NREL    -> etr 989.668518, etrn 1323.239868, etrtilt 1207.547363\n" );
    stdout.printf ( "SOLTEST -> etr %f, etrn %f, etrtilt %f\n",
            pd.etr,    pd.etrn,    pd.etrtilt );
    stdout.printf ( "NREL    -> prime 1.037040, sbcf 1.201910, sunrise 347.173431\n" );
    stdout.printf ( "SOLTEST -> prime %f, sbcf %f, sunrise %f\n",
            pd.prime,    pd.sbcf,    pd.sretr );
    stdout.printf ( "NREL    -> sunset 1181.111206, unprime 0.964283, zenref 41.590069\n" );
    stdout.printf ( "SOLTEST -> sunset %f, unprime %f, zenref %f\n",
            pd.ssetr, pd.unprime, pd.zenref );

    // documentation examples, but not commented out
    pd.function = Solpos.CompositeMask.REFRAC;
    pd.function = Solpos.CompositeMask.SBCF;
    pd.function = (Solpos.CompositeMask.REFRAC | Solpos.CompositeMask.SBCF);
    pd.function = ((Solpos.CompositeMask.REFRAC | Solpos.CompositeMask.SBCF) & ~Solpos.CompositeMask.DOY);
    pd.month = 7;
    pd.day = 22;
    pd.function |= Solpos.CompositeMask.DOY;
    pd.month = -99;
    pd.day = -99;
    pd.function &= ~Solpos.CompositeMask.DOY;
    pd.year = 99;
    
    pd.function = Solpos.FunctionMask.AMASS;
    pd.press = 1013.0f;
    stdout.printf( "Raw airmass loop:\n");
    stdout.printf( "NREL    -> 37.92  5.59  2.90  1.99  1.55  1.30  1.15  1.06  1.02  1.00\n");
    stdout.printf( "SOLTEST -> ");

    for (pd.zenref = 90.0f; pd.zenref >= 0.0f; pd.zenref -= 10.0f) {
        retval = pd.solpos ();
        pd.decode (retval);
        stdout.printf("%5.2f ", pd.amass);
    }
    stdout.printf("\n");

    return 0;
}
