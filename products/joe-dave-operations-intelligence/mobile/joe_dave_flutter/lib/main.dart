import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const apiRoot = 'https://joe-dave-operations-api.uchechukwuanuforo.workers.dev';
const blue = Color(0xFF246BCE);
const ink = Color(0xFF142B4A);
const canvas = Color(0xFFF5F8FC);

void main() => runApp(const JoeDaveApp());

class JoeDaveApp extends StatefulWidget {
  const JoeDaveApp({super.key});
  @override State<JoeDaveApp> createState() => _JoeDaveAppState();
}
class _JoeDaveAppState extends State<JoeDaveApp> {
  String? token;
  Map<String,dynamic> profile = {};
  bool loading = true;
  @override void initState() { super.initState(); _restore(); }
  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('jd_token');
    if (saved != null && saved.isNotEmpty) {
      try {
        final me = await Api(saved).get('/auth/me');
        if (mounted) setState(() { token=saved; profile=me; loading=false; });
        return;
      } catch (_) { await prefs.remove('jd_token'); }
    }
    if (mounted) setState(() => loading=false);
  }
  Future<void> _signedIn(String value, Map<String,dynamic> user) async {
    final prefs=await SharedPreferences.getInstance();
    await prefs.setString('jd_token',value);
    if(mounted) setState(() {token=value; profile=user;});
  }
  Future<void> _signOut() async {
    final old=token;
    final prefs=await SharedPreferences.getInstance();
    await prefs.remove('jd_token');
    if(old!=null){try{await Api(old).post('/auth/logout',{});}catch(_){}}
    if(mounted)setState((){token=null;profile={};});
  }
  @override Widget build(BuildContext context) => MaterialApp(
    title:'Joe&dave', debugShowCheckedModeBanner:false,
    theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:canvas,
      colorScheme:ColorScheme.fromSeed(seedColor:blue),
      appBarTheme:const AppBarTheme(backgroundColor:Colors.white,foregroundColor:ink,elevation:0),
      cardTheme:CardThemeData(color:Colors.white,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18),side:const BorderSide(color:Color(0xFFE7EDF5)))),
      inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(13)))),
    home:loading?const Scaffold(body:Center(child:CircularProgressIndicator())):
      token==null?SignIn(onSignedIn:_signedIn):Home(token:token!,profile:profile,onSignOut:_signOut));
}

class Api {
  final String? token;
  Api([this.token]);
  Future<Map<String,dynamic>> _send(String method,String path,[Map<String,dynamic>? body]) async {
    final request=http.Request(method,Uri.parse(apiRoot+path));
    request.headers.addAll({'Accept':'application/json','Content-Type':'application/json'});
    if(token!=null)request.headers['Authorization']='Bearer '+token!;
    if(body!=null)request.body=jsonEncode(body);
    final streamed=await request.send().timeout(const Duration(seconds:25));
    final response=await http.Response.fromStream(streamed);
    dynamic decoded;
    try{decoded=jsonDecode(response.body);}catch(_){decoded={'error':'The server returned an unreadable response.'};}
    if(response.statusCode<200||response.statusCode>=300){
      final message=decoded is Map?(decoded['error']??decoded['message']??'Request failed'): 'Request failed ('+response.statusCode.toString()+')';
      throw Exception(message.toString());
    }
    return decoded is Map<String,dynamic>?decoded:{'data':decoded};
  }
  Future<Map<String,dynamic>> get(String p)=>_send('GET',p);
  Future<Map<String,dynamic>> post(String p,Map<String,dynamic> b)=>_send('POST',p,b);
}

class SignIn extends StatefulWidget {
  final Future<void> Function(String,Map<String,dynamic>) onSignedIn;
  const SignIn({super.key,required this.onSignedIn});
  @override State<SignIn> createState()=>_SignInState();
}
class _SignInState extends State<SignIn> {
  final email=TextEditingController(),password=TextEditingController(),business=TextEditingController();
  bool register=false,busy=false,obscure=true;
  String? error;
  Future<void> submit() async {
    setState(()=>{busy=true,error=null});
    try{
      final result=await Api().post(register?'/auth/register':'/auth/login',{
        'email':email.text.trim(),'password':password.text,
        if(register)'business_name':business.text.trim(),
        if(register)'display_name':business.text.trim(),'currency_code':'NGN'});
      await widget.onSignedIn(result['token'] as String,result);
    }catch(e){if(mounted)setState(()=>error=e.toString().replaceFirst('Exception: ',''));}
    finally{if(mounted)setState(()=>busy=false);}
  }
  @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:440),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
    Container(height:58,width:58,alignment:Alignment.center,decoration:BoxDecoration(color:blue,borderRadius:BorderRadius.circular(18)),child:const Icon(Icons.insights_rounded,color:Colors.white,size:30)),
    const SizedBox(height:24),const Text('Joe&dave',style:TextStyle(fontSize:30,fontWeight:FontWeight.w800,color:ink)),
    const Text('Operations Intelligence',style:TextStyle(color:Colors.blueGrey)),
    const SizedBox(height:30),Text(register?'Create your business workspace':'Welcome back',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w700,color:ink)),
    const SizedBox(height:18),
    if(register)...[TextField(controller:business,decoration:const InputDecoration(labelText:'Business name',prefixIcon:Icon(Icons.business_outlined))),const SizedBox(height:12)],
    TextField(controller:email,keyboardType:TextInputType.emailAddress,autocorrect:false,decoration:const InputDecoration(labelText:'Email address',prefixIcon:Icon(Icons.email_outlined))),
    const SizedBox(height:12),TextField(controller:password,obscureText:obscure,decoration:InputDecoration(labelText:'Password',prefixIcon:const Icon(Icons.lock_outline),suffixIcon:IconButton(onPressed:()=>setState(()=>obscure=!obscure),icon:Icon(obscure?Icons.visibility_outlined:Icons.visibility_off_outlined)))),
    if(register)const Padding(padding:EdgeInsets.only(top:8),child:Text('Use at least 12 characters for your password.',style:TextStyle(color:Colors.blueGrey,fontSize:12))),
    if(error!=null)Padding(padding:const EdgeInsets.only(top:12),child:Text(error!,style:const TextStyle(color:Colors.red))),
    const SizedBox(height:20),FilledButton(onPressed:busy?null:submit,style:FilledButton.styleFrom(minimumSize:const Size.fromHeight(52),backgroundColor:blue),child:busy?const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)):Text(register?'Create workspace':'Sign in')),
    TextButton(onPressed:busy?null:()=>setState(()=>{register=!register,error=null}),child:Text(register?'Already have an account? Sign in':'Create a new business workspace'))
  ]))))));
}

class Home extends StatefulWidget {
 final String token; final Map<String,dynamic> profile; final Future<void> Function() onSignOut;
 const Home({super.key,required this.token,required this.profile,required this.onSignOut});
 @override State<Home> createState()=>_HomeState();
}
class _HomeState extends State<Home> {
 int selected=0;
 static const modules=[
  ('Overview',Icons.grid_view_rounded,'/dashboard'),
  ('Sales',Icons.point_of_sale_rounded,'/invoices'),
  ('Customers',Icons.people_alt_outlined,'/customers'),
  ('Inventory',Icons.inventory_2_outlined,'/inventory'),
  ('Analytics',Icons.query_stats_rounded,'/analytics')];
 @override Widget build(BuildContext context){
  final b=widget.profile['business'] is Map?widget.profile['business'] as Map:{};
  return Scaffold(appBar:AppBar(title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   const Text('Joe&dave',style:TextStyle(fontWeight:FontWeight.w800)),
   Text((b['display_name']??'Operations workspace').toString(),style:const TextStyle(fontSize:12,color:Colors.blueGrey))]),
   actions:[IconButton(tooltip:'Sign out',onPressed:widget.onSignOut,icon:const Icon(Icons.logout_rounded))]),
   body:ModulePage(token:widget.token,module:modules[selected]),
   bottomNavigationBar:NavigationBar(selectedIndex:selected,onDestinationSelected:(v)=>setState(()=>selected=v),backgroundColor:Colors.white,indicatorColor:const Color(0xFFE4EEFC),destinations:const [
    NavigationDestination(icon:Icon(Icons.grid_view_rounded),label:'Home'),
    NavigationDestination(icon:Icon(Icons.point_of_sale_rounded),label:'Sales'),
    NavigationDestination(icon:Icon(Icons.people_alt_outlined),label:'Customers'),
    NavigationDestination(icon:Icon(Icons.inventory_2_outlined),label:'Stock'),
    NavigationDestination(icon:Icon(Icons.query_stats_rounded),label:'Insights')]));
 }
}

class ModulePage extends StatefulWidget {
 final String token; final (String,IconData,String) module;
 const ModulePage({super.key,required this.token,required this.module});
 @override State<ModulePage> createState()=>_ModulePageState();
}
class _ModulePageState extends State<ModulePage> {
 late Future<Map<String,dynamic>> future;
 @override void initState(){super.initState();future=Api(widget.token).get(widget.module.$3);}
 @override void didUpdateWidget(covariant ModulePage old){super.didUpdateWidget(old);if(old.module.$3!=widget.module.$3)future=Api(widget.token).get(widget.module.$3);}
 @override Widget build(BuildContext context)=>RefreshIndicator(onRefresh:()async{setState(()=>future=Api(widget.token).get(widget.module.$3));await future;},child:FutureBuilder<Map<String,dynamic>>(future:future,builder:(context,s){
  if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
  if(s.hasError)return ListView(padding:const EdgeInsets.all(22),children:[const SizedBox(height:70),const Icon(Icons.cloud_off_outlined,size:48,color:Colors.blueGrey),const SizedBox(height:12),Text('Could not load '+widget.module.$1.toLowerCase(),textAlign:TextAlign.center,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w700)),const SizedBox(height:8),Text(s.error.toString().replaceFirst('Exception: ',''),textAlign:TextAlign.center,style:const TextStyle(color:Colors.blueGrey)),const SizedBox(height:14),OutlinedButton(onPressed:()=>setState(()=>future=Api(widget.token).get(widget.module.$3)),child:const Text('Try again'))]);
  final data=s.data??{};
  return ListView(padding:const EdgeInsets.fromLTRB(18,18,18,28),children:[
   Text(widget.module.$1,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w800,color:ink)),
   const SizedBox(height:4),const Text('Live workspace data',style:TextStyle(color:Colors.blueGrey)),const SizedBox(height:18),
   if(widget.module.$3=='/dashboard'||widget.module.$3=='/analytics')..._summaryCards(data),
   ..._recordSections(data),
   if(data.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(20),child:Text('No records are available for this workspace yet.')))
  ]);
 }));
 }
 List<Widget> _summaryCards(Map<String,dynamic> data){
  final entries=<MapEntry<String,dynamic>>[];
  void collect(Map m){m.forEach((k,v){if(v is num)entries.add(MapEntry(k,v));else if(v is Map)collect(v);});}
  collect(data);
  return [Wrap(spacing:10,runSpacing:10,children:entries.take(8).map((e)=>SizedBox(width:MediaQuery.of(context).size.width>600?180:(MediaQuery.of(context).size.width-46)/2,child:Card(child:Padding(padding:const EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Text(label(e.key),style:const TextStyle(color:Colors.blueGrey,fontSize:12)),const SizedBox(height:8),
   Text(e.value.toString(),style:const TextStyle(fontSize:24,fontWeight:FontWeight.w800,color:ink))]))))).toList()),const SizedBox(height:18)];
 }
 List<Widget> _recordSections(Map<String,dynamic> data){
  final out=<Widget>[];
  data.forEach((key,value){
   if(value is List){
    out.add(Padding(padding:const EdgeInsets.only(bottom:8),child:Text(label(key),style:const TextStyle(fontSize:17,fontWeight:FontWeight.w700,color:ink))));
    if(value.isEmpty)out.add(const Text('Nothing to show yet.',style:TextStyle(color:Colors.blueGrey)));
    for(final row in value.take(40)){
     if(row is Map){
      final m=Map<String,dynamic>.from(row);
      final title=(m['name']??m['display_name']??m['customer_name']??m['item_name']??m['invoice_number']??m['id']??'Record').toString();
      final subtitle=m.entries.where((e)=>e.value!=null&&e.key!='id'&&e.key!='name').take(3).map((e)=>label(e.key)+': '+e.value.toString()).join('  •  ');
      out.add(Card(child:ListTile(title:Text(title,maxLines:1,overflow:TextOverflow.ellipsis),subtitle:subtitle.isEmpty?null:Text(subtitle,maxLines:2,overflow:TextOverflow.ellipsis),leading:const CircleAvatar(backgroundColor:Color(0xFFEAF1FC),child:Icon(Icons.description_outlined,color:blue))));
     }
    }
    out.add(const SizedBox(height:14));
   }else if(value is Map){out.addAll(_recordSections(Map<String,dynamic>.from(value)));}
  });
  return out;
 }
 String label(String s)=>s.replaceAll('_',' ').split(' ').map((w)=>w.isEmpty?w:w[0].toUpperCase()+w.substring(1)).join(' ');
}
