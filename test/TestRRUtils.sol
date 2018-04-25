import "truffle/Assert.sol";
import "../contracts/RRUtils.sol";
import "../contracts/BytesUtils.sol";

contract TestRRUtils {
  using BytesUtils for *;
  using RRUtils for *;

  uint16 constant DNSTYPE_A = 1;
  uint16 constant DNSTYPE_CNAME = 5;
  uint16 constant DNSTYPE_MX = 15;
  uint16 constant DNSTYPE_RRSIG = 46;
  uint16 constant DNSTYPE_NSEC = 47;
  uint16 constant DNSTYPE_TYPE1234 = 1234;

  function testCheckTypeBitmap() public {
    // From https://tools.ietf.org/html/rfc4034#section-4.3
    //    alfa.example.com. 86400 IN NSEC host.example.com. (
    //                               A MX RRSIG NSEC TYPE1234
    bytes memory tb = hex'0006400100000003041b000000000000000000000000000000000000000000000000000020';

    // Exists in bitmap
    Assert.equal(tb.checkTypeBitmap(0, DNSTYPE_A), true, "A record should exist in type bitmap");
    // Does not exist, but in a window that is included
    Assert.equal(tb.checkTypeBitmap(0, DNSTYPE_CNAME), false, "CNAME record should not exist in type bitmap");
    // Does not exist, past the end of a window that is included
    Assert.equal(tb.checkTypeBitmap(0, 64), false, "Type 64 should not exist in type bitmap");
    // Does not exist, in a window that does not exist
    Assert.equal(tb.checkTypeBitmap(0, 769), false, "Type 769 should not exist in type bitmap");
    // Exists in a subsequent window
    Assert.equal(tb.checkTypeBitmap(0, DNSTYPE_TYPE1234), true, "Type 1234 should exist in type bitmap");
    // Does not exist, past the end of the bitmap windows
    Assert.equal(tb.checkTypeBitmap(0, 1281), false, "Type 1281 should not exist in type bitmap");
  }
}