//user model
class UserDetails{
   String name = "";
  String bearer="";
  String email = "";
  String phoneNumber="";
  String id="";
  String avatar="";
  String role = "";
  String canCreate= "";

  UserDetails({
    this.name,
    this.bearer,
    this.id,
    this.avatar,
    this.email,
    this.phoneNumber,
    this.canCreate,
    this.role,
  });
}