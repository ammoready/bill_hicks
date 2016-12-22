module SampleFiles

  def sample_ack_file
    <<-TXT
ACK|PO Date|PO Ack Date|PO Number|Quantity Ordered|Quantity Committed|Product ID|UPC Number|Unit of Measure|Price|Shipto Name|Shipto Address1|Shipto Address2|Shipto City|Shipto State|Shipto Zip Code|BHC Order Number
AckData|02/10/201|41680|999999910|6|6|ABC-987|123456789123|EA|1.00|Customer 1|1234 Main Street||Anywhere|CO|81154|1234567
AckData|02/10/201|41680|999999910|4|2|ABC-999|987654321987|EA|2.00|Customer 2|65421 Dale Ave|Apt 200|Anywhere|CA|98547|1234567
AckData|02/10/201|41680|999999910|8|5|ABC-321|999888777526|EA|9.22|Customer 3|999 First Street||Anywhere|MD|98754|1234567
    TXT
  end

  def sample_asn_file
    <<-TXT
ASN|PO Date|Ship Date|PO Number|Quantity Ordered|Quantity Shipped|Product ID|UPC Number|Unit of Measure|Price|Shipto Name|Shipto Address1|Shipto Address2|Shipto City|Shipto State|Shipto Zip Code|Tracking Number|Carrier|BHC Order Number
ASNData|02/10/2014|41682|999999910|6|6|ABC-987|987658741235|EA|1.00|Customer 1|1234 Main Street||Anywhere|CO|81154|1Z3698754124255|UPSG|1234567
    TXT
  end

  def sample_bad_asn_file
    <<-TXT
ASN|PO Date|Ship Date|PO Number|Quantity Ordered|Quantity Shipped|Product ID|UPC Number|Unit of Measure|Price|Shipto Name|Shipto Address1|Shipto Address2|Shipto City|Shipto State|Shipto Zip Code|Tracking Number|Carrier|BHC Order Number
ASNData|02/10/2014|41682|999999910|6|6|ABC-987|987658741235|EA|Customer 1|1234 Main Street||Anywhere|CO|81154|1Z3698754124255|UPSG|1234567
    TXT
  end

end
