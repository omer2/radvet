# Introduction #

The GST amounts are calculated incorrectly for the 12.5% NZ GST rate. Run this script and when applied to the database will correctly fix up the GST.


# Details #

**Before running this script read the Wiki entry on connecting to the database**

**Run the following script to add the following two triggers to the database**

```
/* Definition for the `VISITSTOCK_GST` trigger :  */

SET TERM ^ ;

CREATE TRIGGER VISITSTOCK_GST FOR VISITSTOCK
ACTIVE BEFORE INSERT OR UPDATE
POSITION 0
AS
BEGIN
  NEW.TAX = NEW.TOTALPRICE - (NEW.TOTALPRICE / 1.125);
  NEW.SELLINGPRICE = (NEW.TOTALPRICE / 1.125);
END^

SET TERM ; ^

/* Definition for the `PAYMENT_GST` trigger :  */

SET TERM ^ ;

CREATE TRIGGER PAYMENT_GST FOR PAYMENT
ACTIVE BEFORE INSERT OR UPDATE
POSITION 0
AS
BEGIN
  NEW.TAX = NEW.AMOUNT - (NEW.AMOUNT / 1.125);
END^

SET TERM ; ^

```