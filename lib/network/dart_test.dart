var uri = "https://ios.sspai.com/post/233333";
var whitelist = ["https://ios.sspai.com/post/"];

void main(){
  for (String entry in whitelist) {
    if (uri.contains(entry)) {
      print("true");
    } else {
      print("F");
    }
  }
}