import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'module_specs.dart';

const apiRoot='https://joe-dave-operations-api.uchechukwuanuforo.workers.dev';
const blue=Color(0xFF246BCE),navy=Color(0xFF142B4A),bg=Color(0xFFF4F7FB);
const groupIcons=<String,IconData>{
 'Finance & Accounts':Icons.account_balance_wallet_outlined,'Sales & CRM':Icons.point_of_sale_rounded,
 'Inventory':Icons.inventory_2_outlined,'Buying':Icons.shopping_cart_outlined,
 'People & Payroll':Icons.groups_outlined,'Manufacturing':Icons.precision_manufacturing_outlined,
 'Projects':Icons.assignment_outlined,'Helpdesk':Icons.support_agent_outlined,'Reports':Icons.query_stats_rounded,
 'Sales Intelligence':Icons.insights_rounded
};
const special=< (String,String) >[
 ('Sales intelligence overview','/sales-intelligence/overview'),('Prospects','/sales-intelligence/prospects'),
 ('Market signals','/sales-intelligence/signals'),('Campaigns','/sales-intelligence/campaigns'),
 ('Draft outbox','/sales-intelligence/outbox'),('Replies','/sales-intelligence/replies'),
 ('Suppression list','/sales-intelligence/suppressions')
];
void main()=>runApp(const JoeDaveApp());

class JoeDaveApp extends StatefulWidget{const JoeDaveApp({super.key});@override State<JoeDaveApp> createState()=>_JoeDaveAppState();}
class _JoeDaveAppState extends State<JoeDaveApp>{
 String? token;Map<String,dynamic> profile={};bool loading=true;
 @override void initState(){super.initState();restore();}
 Future<void> restore()async{
  final p=await SharedPreferences.getInstance(),saved=p.getString('jd_token');
  if(saved!=null){try{final me=await Api(saved).get('/auth/me');if(mounted)setState(() { token=saved; profile=me; loading=false; });return;}catch(_){await p.remove('jd_token');}}
  if(mounted)setState(() { loading=false; });
 }
 Future<void> signedIn(String t,Map<String,dynamic> p)async{final s=await SharedPreferences.getInstance();await s.setString('jd_token',t);if(mounted)setState(() { token=t; profile=p; });}
 Future<void> signOut()async{final t=token;final p=await SharedPreferences.getInstance();await p.remove('jd_token');if(t!=null){try{await Api(t).post('/auth/logout',{});}catch(_){}}if(mounted)setState(() { token=null; profile={}; });}
 @override Widget build(BuildContext context)=>MaterialApp(title:'Joe&dave',debugShowCheckedModeBanner:false,
  theme:ThemeData(useMaterial3:true,scaffoldBackgroundColor:bg,colorScheme:ColorScheme.fromSeed(seedColor:blue),
   appBarTheme:const AppBarTheme(backgroundColor:Colors.white,foregroundColor:navy,elevation:0),
   cardTheme:CardThemeData(color:Colors.white,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16),side:const BorderSide(color:Color(0xFFE5EBF3)))),
   inputDecorationTheme:InputDecorationTheme(filled:true,fillColor:Colors.white,border:OutlineInputBorder(borderRadius:BorderRadius.circular(12)))),
  home:loading?const Scaffold(body:Center(child:CircularProgressIndicator())):token==null?LoginScreen(onLogin:signedIn):Workspace(token:token!,profile:profile,onLogout:signOut));
}

class Api{
 final String token;Api(this.token);
 Future<Map<String,dynamic>> send(String method,String path,[Map<String,dynamic>? body])async{
  final q=http.Request(method,Uri.parse(apiRoot+path));
  q.headers.addAll({'Accept':'application/json','Content-Type':'application/json','Authorization':'Bearer '+token});
  if(body!=null)q.body=jsonEncode(body);
  final stream=await q.send().timeout(const Duration(seconds:30)),r=await http.Response.fromStream(stream);
  dynamic d;try{d=jsonDecode(r.body);}catch(_){d={'error':'Invalid server response'};}
  if(r.statusCode<200||r.statusCode>=300)throw Exception((d is Map?d['error']:'Request failed')?.toString()??'Request failed');
  return d is Map<String,dynamic>?d:{'data':d};
 }
 Future<Map<String,dynamic>> get(String p)=>send('GET',p);
 Future<Map<String,dynamic>> post(String p,Map<String,dynamic> b)=>send('POST',p,b);
 Future<Map<String,dynamic>> put(String p,Map<String,dynamic> b)=>send('PUT',p,b);
 Future<Map<String,dynamic>> delete(String p)=>send('DELETE',p);
}

class LoginScreen extends StatefulWidget{
 final Future<void> Function(String,Map<String,dynamic>) onLogin;const LoginScreen({super.key,required this.onLogin});
 @override State<LoginScreen> createState()=>_LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen>{
 final email=TextEditingController(),password=TextEditingController(),business=TextEditingController();
 bool create=false,busy=false,hide=true;String? error;
 Future<void> submit()async{
  if(email.text.trim().isEmpty||password.text.isEmpty||(create&&business.text.trim().isEmpty)){setState(()=>error='Complete all required fields.');return;}
  setState(() { busy=true; error=null; });
  try{final d=await httpPost(create?'/auth/register':'/auth/login',{
   'email':email.text.trim(),'password':password.text,'business_name':business.text.trim(),'display_name':business.text.trim(),'currency_code':'NGN'});
   final t=d['token'];if(t is! String)throw Exception('No session token returned.');await widget.onLogin(t,d);
  }catch(e){if(mounted)setState(()=>error=e.toString());}finally{if(mounted)setState(()=>busy=false);}
 }
 Future<Map<String,dynamic>> httpPost(String p,Map<String,dynamic> b)async{
  final r=await http.post(Uri.parse(apiRoot+p),headers:{'Content-Type':'application/json'},body:jsonEncode(b)).timeout(const Duration(seconds:30));
  final d=jsonDecode(r.body);if(r.statusCode<200||r.statusCode>=300)throw Exception(d['error']??'Sign in failed');return Map<String,dynamic>.from(d);
 }
 @override Widget build(BuildContext context)=>Scaffold(body:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:440),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
  Container(height:60,width:60,alignment:Alignment.center,decoration:BoxDecoration(color:blue,borderRadius:BorderRadius.circular(18)),child:const Icon(Icons.insights_rounded,color:Colors.white,size:32)),
  const SizedBox(height:24),const Text('Joe&dave',style:TextStyle(fontSize:32,fontWeight:FontWeight.w900,color:navy)),const Text('Operations Intelligence',style:TextStyle(color:Colors.blueGrey)),
  const SizedBox(height:30),Text(create?'Create your business workspace':'Welcome back',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:navy)),
  if(create)...[const SizedBox(height:16),TextField(controller:business,decoration:const InputDecoration(labelText:'Business name',prefixIcon:Icon(Icons.business_outlined)))],
  const SizedBox(height:14),TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Email address',prefixIcon:Icon(Icons.email_outlined))),
  const SizedBox(height:12),TextField(controller:password,obscureText:hide,decoration:InputDecoration(labelText:'Password',prefixIcon:const Icon(Icons.lock_outline),suffixIcon:IconButton(onPressed:()=>setState(()=>hide=!hide),icon:Icon(hide?Icons.visibility_outlined:Icons.visibility_off_outlined)))),
  if(create)const Padding(padding:EdgeInsets.only(top:8),child:Text('Password must be at least 12 characters.',style:TextStyle(color:Colors.blueGrey,fontSize:12))),
  if(error!=null)Padding(padding:const EdgeInsets.only(top:12),child:Text(error!,style:const TextStyle(color:Colors.red))),
  const SizedBox(height:20),FilledButton(onPressed:busy?null:submit,style:FilledButton.styleFrom(backgroundColor:blue,minimumSize:const Size.fromHeight(52)),child:busy?const CircularProgressIndicator(color:Colors.white):Text(create?'Create workspace':'Sign in')),
  TextButton(onPressed:busy?null:()=>setState(() { create=!create; error=null; }),child:Text(create?'Already registered? Sign in':'Create a new business workspace'))
 ]))))));
}

class Workspace extends StatefulWidget{
 final String token;final Map<String,dynamic> profile;final Future<void> Function() onLogout;
 const Workspace({super.key,required this.token,required this.profile,required this.onLogout});
 @override State<Workspace> createState()=>_WorkspaceState();
}
class _WorkspaceState extends State<Workspace>{
 String current='home';
 String get businessName{final b=profile['business'];return b is Map?(b['display_name']??b['legal_name']??'Business workspace').toString():'Business workspace';}
 @override Widget build(BuildContext context){
  final wide=MediaQuery.of(context).size.width>900;
  final spec=moduleSpecs.where((m)=>m.key==current).toList();
  final sp=special.where((m)=>m.$2==current).toList();
  Widget page=current=='home'?Dashboard(token:widget.token,onSelect:(v)=>setState(()=>current=v)):
   current=='settings'?Settings(profile:widget.profile):
   spec.isNotEmpty?ModulePage(key:ValueKey(current),token:widget.token,spec:spec.first):
   current=='team'?TeamMembersPage(token:widget.token):
   current=='business-settings'?BusinessSettingsPage(token:widget.token):
   current=='inventory-import'?InventoryImportPage(token:widget.token):
   sp.isNotEmpty?SpecialPage(key:ValueKey(current),token:widget.token,title:sp.first.$1,path:sp.first.$2):Dashboard(token:widget.token,onSelect:(v)=>setState(()=>current=v));
  return Scaffold(appBar:AppBar(title:Row(children:[const Icon(Icons.insights_rounded,color:blue),const SizedBox(width:8),const Text('Joe&dave',style:TextStyle(fontWeight:FontWeight.w900)),if(wide)Flexible(child:Text('  ·  '+businessName,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:12,color:Colors.blueGrey)))]),
   actions:[PopupMenuButton<String>(onSelected:(v){if(v=='settings')setState(()=>current='settings');if(v=='logout')widget.onLogout();},itemBuilder:(_)=>const [PopupMenuItem(value:'settings',child:Text('Workspace settings')),PopupMenuItem(value:'logout',child:Text('Sign out'))])]),
   drawer:wide?null:Drawer(child:menu()),
   body:wide?Row(children:[SizedBox(width:285,child:menu()),const VerticalDivider(width:1),Expanded(child:page)]):page,
   bottomNavigationBar:wide?null:NavigationBar(selectedIndex:current=='home'?0:1,onDestinationSelected:(i)=>setState(()=>current=i==0?'home':'settings'),destinations:const [NavigationDestination(icon:Icon(Icons.dashboard_outlined),label:'Overview'),NavigationDestination(icon:Icon(Icons.settings_outlined),label:'Settings')]));
 }
 Widget menu()=>SafeArea(child:Column(children:[
  Padding(padding:const EdgeInsets.all(16),child:Text(businessName,style:const TextStyle(fontWeight:FontWeight.w800,color:navy))),
  ListTile(selected:current=='home',leading:const Icon(Icons.dashboard_outlined),title:const Text('Overview'),onTap:()=>choose('home')),
  ListTile(selected:current=='business-settings',leading:const Icon(Icons.business_outlined),title:const Text('Business profile & branding'),onTap:()=>choose('business-settings')),
  ListTile(selected:current=='team',leading:const Icon(Icons.manage_accounts_outlined),title:const Text('Team & permissions'),onTap:()=>choose('team')),
  ListTile(selected:current=='inventory-import',leading:const Icon(Icons.file_upload_outlined),title:const Text('Inventory CSV import'),onTap:()=>choose('inventory-import')),
  Expanded(child:ListView(children:[
   for(final group in moduleGroups.entries)ExpansionTile(leading:Icon(groupIcons[group.key]??Icons.folder_outlined,color:blue),title:Text(group.key,style:const TextStyle(fontWeight:FontWeight.w700)),initiallyExpanded:group.value.contains(current),children:[
    for(final k in group.value)Builder(builder:(ctx){final m=moduleSpecs.firstWhere((x)=>x.key==k);return ListTile(dense:true,selected:current==k,title:Text(m.title),contentPadding:const EdgeInsets.only(left:54,right:12),onTap:()=>choose(k));})
   ]),
   ExpansionTile(leading:const Icon(Icons.insights_rounded,color:blue),title:const Text('Sales Intelligence',style:TextStyle(fontWeight:FontWeight.w700)),children:[for(final s in special)ListTile(dense:true,title:Text(s.$1),contentPadding:const EdgeInsets.only(left:54),selected:current==s.$2,onTap:()=>choose(s.$2))])
  ])),
  ListTile(leading:const Icon(Icons.settings_outlined),title:const Text('Settings'),onTap:()=>choose('settings')),
  ListTile(leading:const Icon(Icons.logout),title:const Text('Sign out'),onTap:widget.onLogout)
 ]));
 void choose(String k){setState(()=>current=k);if(MediaQuery.of(context).size.width<=900)Navigator.pop(context);}
}

class Dashboard extends StatefulWidget{
 final String token;final ValueChanged<String> onSelect;const Dashboard({super.key,required this.token,required this.onSelect});
 @override State<Dashboard> createState()=>_DashboardState();
}
class _DashboardState extends State<Dashboard>{
 late Future<Map<String,dynamic>> future;
 @override void initState(){super.initState();future=Api(widget.token).get('/dashboard');}
 Future<void> refresh()async{setState(()=>future=Api(widget.token).get('/dashboard'));await future;}
 @override Widget build(BuildContext context)=>FutureBuilder<Map<String,dynamic>>(future:future,builder:(context,s){
  if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
  if(s.hasError)return ErrorView(message:s.error.toString(),retry:refresh);
  final data=s.data??{},metrics=<MapEntry<String,dynamic>>[];
  void collect(Map m){m.forEach((k,v){if(v is num)metrics.add(MapEntry(k,v));else if(v is Map)collect(v);});}collect(data);
  final quick=< (String,String,IconData) >[
   ('finance/invoices','Invoices',Icons.receipt_long_outlined),('finance/customers','Customers',Icons.people_outline),
   ('inventory/items','Items & stock',Icons.inventory_2_outlined),('buying/orders','Purchase orders',Icons.shopping_cart_outlined),
   ('hr/employees','Employees',Icons.groups_outlined),('finance/profit-loss','Profit & loss',Icons.query_stats_outlined)
  ];
  return RefreshIndicator(onRefresh:refresh,child:ListView(padding:const EdgeInsets.all(20),children:[
   const Text('Operations Intelligence',style:TextStyle(color:Colors.blueGrey)),const Text('Business overview',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900,color:navy)),
   const SizedBox(height:18),
   if(metrics.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('Live business metrics will appear here as transactions are recorded.')))
   else Wrap(spacing:10,runSpacing:10,children:[for(final m in metrics.take(8))SizedBox(width:MediaQuery.of(context).size.width>700?190:(MediaQuery.of(context).size.width-52)/2,child:Card(child:Padding(padding:const EdgeInsets.all(15),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(human(m.key),style:const TextStyle(color:Colors.blueGrey,fontSize:12)),const SizedBox(height:8),Text(m.value.toString(),style:const TextStyle(fontSize:24,fontWeight:FontWeight.w900,color:navy))]))))]),
   const SizedBox(height:22),const Text('Quick access',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:navy)),const SizedBox(height:10),
   GridView.count(shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),crossAxisCount:MediaQuery.of(context).size.width>700?3:2,childAspectRatio:1.8,crossAxisSpacing:10,mainAxisSpacing:10,children:[for(final q in quick)InkWell(onTap:()=>widget.onSelect(q.$1),borderRadius:BorderRadius.circular(16),child:Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(q.$3,color:blue),const SizedBox(height:7),Text(q.$2,style:const TextStyle(fontWeight:FontWeight.w700,color:navy))]))))]),
   const SizedBox(height:22),const Text('Business functions',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:navy)),
   for(final g in moduleGroups.entries)Card(child:ListTile(leading:Icon(groupIcons[g.key],color:blue),title:Text(g.key,style:const TextStyle(fontWeight:FontWeight.w700)),subtitle:Text(g.value.length.toString()+' modules'),trailing:const Icon(Icons.chevron_right),onTap:()=>widget.onSelect(g.value.first)))
  ]));
 });
}

class ModulePage extends StatefulWidget{
 final String token;final ModuleSpec spec;const ModulePage({super.key,required this.token,required this.spec});
 @override State<ModulePage> createState()=>_ModulePageState();
}
class _ModulePageState extends State<ModulePage>{
 late Future<List<Map<String,dynamic>>> future;String query='';
 String get route=>widget.spec.apiRoute??'/ops/'+widget.spec.key;
 @override void initState(){super.initState();future=load();}
 Future<List<Map<String,dynamic>>> load()async{
  final d=await Api(widget.token).get(route),raw=d[widget.spec.collectionKey??'records']??d['records']??d['data']??[];
  if(raw is List)return raw.whereType<Map>().map((x)=>Map<String,dynamic>.from(x)).toList();
  if(raw is Map)return [Map<String,dynamic>.from(raw)];return [];
 }
 Future<void> refresh()async{setState(()=>future=load());await future;}
 Future<void> add()async{
  if(widget.spec.readOnly)return;
  final v=await showDialog<Map<String,dynamic>>(context:context,builder:(_)=>RecordDialog(spec:widget.spec));
  if(v==null)return;
  try{await Api(widget.token).post(route,v);await refresh();snack('Record created.');}catch(e){snack(e.toString());}
 }
 Future<void> edit(Map<String,dynamic> row)async{
  final id=row['id']?.toString();if(id==null||widget.spec.readOnly)return;
  final v=await showDialog<Map<String,dynamic>>(context:context,builder:(_)=>RecordDialog(spec:widget.spec,initial:row));
  if(v==null)return;
  try{await Api(widget.token).put(route+'/'+id,v);await refresh();snack('Changes saved.');}catch(e){snack(e.toString());}
 }
 Future<void> remove(Map<String,dynamic> row)async{
  final id=row['id']?.toString();if(id==null)return;
  final yes=await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:const Text('Delete draft record?'),content:const Text('Posted or finalized records are protected by the server.'),actions:[TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(c,true),child:const Text('Delete'))]));
  if(yes!=true)return;try{await Api(widget.token).delete(route+'/'+id);await refresh();snack('Record deleted.');}catch(e){snack(e.toString());}
 }
 void snack(String s)=>ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));
 @override Widget build(BuildContext context)=>Column(children:[
  Padding(padding:const EdgeInsets.fromLTRB(18,18,18,10),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.spec.group,style:const TextStyle(fontSize:12,color:Colors.blueGrey)),Text(widget.spec.title,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:navy))])),if(!widget.spec.readOnly)FilledButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('Add'))])),
  Padding(padding:const EdgeInsets.fromLTRB(18,0,18,12),child:TextField(onChanged:(v)=>setState(()=>query=v),decoration:InputDecoration(prefixIcon:const Icon(Icons.search),hintText:'Search '+widget.spec.title.toLowerCase(),isDense:true))),
  Expanded(child:RefreshIndicator(onRefresh:refresh,child:FutureBuilder<List<Map<String,dynamic>>>(future:future,builder:(context,s){
   if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
   if(s.hasError)return ErrorView(message:s.error.toString(),retry:refresh);
   final rows=(s.data??[]).where((r)=>r.values.any((v)=>v.toString().toLowerCase().contains(query.toLowerCase()))).toList();
   if(rows.isEmpty)return ListView(children:[const SizedBox(height:80),const Icon(Icons.inbox_outlined,size:48,color:Colors.blueGrey),Center(child:Text(query.isEmpty?'No '+widget.spec.title.toLowerCase()+' yet':'No matching records',style:const TextStyle(color:Colors.blueGrey))),if(!widget.spec.readOnly)Center(child:TextButton.icon(onPressed:add,icon:const Icon(Icons.add),label:const Text('Create record')))]);
   return ListView.separated(padding:const EdgeInsets.fromLTRB(14,0,14,24),itemCount:rows.length,separatorBuilder:(_,__)=>const SizedBox(height:7),itemBuilder:(c,i){
    final r=rows[i],title=primary(r),sub=r.entries.where((e)=>e.key!='id'&&e.value!=null&&e.key!=primaryKey(r)).take(3).map((e)=>human(e.key)+': '+e.value.toString()).join('  •  ');
    return Card(child:ListTile(leading:CircleAvatar(backgroundColor:const Color(0xFFEAF1FC),child:Icon(groupIcons[widget.spec.group]??Icons.folder_outlined,color:blue)),title:Text(title,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontWeight:FontWeight.w700,color:navy)),subtitle:sub.isEmpty?null:Text(sub,maxLines:2,overflow:TextOverflow.ellipsis),trailing:PopupMenuButton<String>(onSelected:(v){if(v=='edit')edit(r);if(v=='delete')remove(r);if(v=='view')details(r);},itemBuilder:(_)=>[const PopupMenuItem(value:'view',child:Text('View details')),if(!widget.spec.readOnly)const PopupMenuItem(value:'edit',child:Text('Edit')),if(!widget.spec.readOnly)const PopupMenuItem(value:'delete',child:Text('Delete draft'))]),onTap:()=>details(r)));
   });
  }))),
 ]);
 String primary(Map<String,dynamic> r){for(final k in ['name','display_name','title','subject','lead_name','employee_number','item_code','code','invoice_number','order_number','ticket_number','request_number','bill_number','quote_number']){if(r[k]!=null&&r[k].toString().isNotEmpty)return r[k].toString();}return 'Record';}
 String primaryKey(Map<String,dynamic> r){for(final k in ['name','display_name','title','subject','lead_name','employee_number','item_code','code','invoice_number','order_number','ticket_number','request_number','bill_number','quote_number']){if(r[k]!=null&&r[k].toString().isNotEmpty)return k;}return 'id';}
 void details(Map<String,dynamic> r)=>showModalBottomSheet(context:context,isScrollControlled:true,showDragHandle:true,builder:(c)=>SafeArea(child:Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.spec.title,style:const TextStyle(color:Colors.blueGrey)),Text(primary(r),style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:navy)),const SizedBox(height:12),Flexible(child:ListView(shrinkWrap:true,children:[for(final e in r.entries)if(e.key!='id'&&e.value!=null)ListTile(dense:true,title:Text(human(e.key),style:const TextStyle(color:Colors.blueGrey,fontSize:12)),subtitle:SelectableText(e.value.toString()))])),if(!widget.spec.readOnly)Row(children:[Expanded(child:OutlinedButton(onPressed:(){Navigator.pop(c);edit(r);},child:const Text('Edit'))),const SizedBox(width:8),Expanded(child:FilledButton(onPressed:(){Navigator.pop(c);remove(r);},child:const Text('Delete')))])]))));
}

class RecordDialog extends StatefulWidget{
 final ModuleSpec spec;final Map<String,dynamic> initial;
 const RecordDialog({super.key,required this.spec,this.initial=const {}});
 @override State<RecordDialog> createState()=>_RecordDialogState();
}
class _RecordDialogState extends State<RecordDialog>{
 final ctrls=<String,TextEditingController>{};final vals=<String,String>{};String? error;
 @override void initState(){super.initState();for(final f in widget.spec.fields){final v=widget.initial[f.key]?.toString()??'';ctrls[f.key]=TextEditingController(text:v);vals[f.key]=v;}}
 @override void dispose(){for(final c in ctrls.values)c.dispose();super.dispose();}
 void save(){
  final out=<String,dynamic>{};
  for(final f in widget.spec.fields){final v=(vals[f.key]??'').trim();if(f.required&&v.isEmpty){setState(()=>error=f.label+' is required.');return;}if(v.isEmpty)continue;
   if(f.type=='number'){final n=num.tryParse(v);if(n==null){setState(()=>error=f.label+' must be numeric.');return;}out[f.key]=n;}else out[f.key]=v;
  }Navigator.pop(context,out);
 }
 @override Widget build(BuildContext context)=>AlertDialog(title:Text(widget.initial.isEmpty?'New '+widget.spec.title:'Edit '+widget.spec.title),content:SizedBox(width:480,child:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[
  for(final f in widget.spec.fields)Padding(padding:const EdgeInsets.only(bottom:11),child:field(f)),
  if(error!=null)Align(alignment:Alignment.centerLeft,child:Text(error!,style:const TextStyle(color:Colors.red)))
 ]))),actions:[TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Cancel')),FilledButton(onPressed:save,child:const Text('Save'))]);
 Widget field(FieldSpec f){
  if(f.type.startsWith('select:')){final options=f.type.substring(7).split('|');return DropdownButtonFormField<String>(value:(vals[f.key]?.isEmpty??true)?null:vals[f.key],decoration:InputDecoration(labelText:f.label+(f.required?' *':'')),items:[for(final o in options)DropdownMenuItem(value:o,child:Text(human(o)))],onChanged:(v)=>setState(()=>vals[f.key]=v??''));}
  if(f.type=='date')return TextField(controller:ctrls[f.key],readOnly:true,decoration:InputDecoration(labelText:f.label+(f.required?' *':''),suffixIcon:const Icon(Icons.calendar_month_outlined)),onTap:()async{final d=await showDatePicker(context:context,initialDate:DateTime.tryParse(vals[f.key]??'')??DateTime.now(),firstDate:DateTime(1990),lastDate:DateTime(2100));if(d!=null)setState(() { vals[f.key]=d.toIso8601String().substring(0,10); ctrls[f.key]!.text=vals[f.key]!; });});
  return TextField(controller:ctrls[f.key],keyboardType:f.type=='number'?const TextInputType.numberWithOptions(decimal:true):f.type=='email'?TextInputType.emailAddress:TextInputType.text,maxLines:f.key.contains('description')||f.key=='notes'||f.key=='body'?3:1,decoration:InputDecoration(labelText:f.label+(f.required?' *':'')),onChanged:(v)=>vals[f.key]=v);
 }
}

class SpecialPage extends StatefulWidget{
 final String token,title,path;const SpecialPage({super.key,required this.token,required this.title,required this.path});
 @override State<SpecialPage> createState()=>_SpecialPageState();
}
class _SpecialPageState extends State<SpecialPage>{
 late Future<Map<String,dynamic>> future;bool busy=false;
 @override void initState(){super.initState();future=Api(widget.token).get(widget.path);}
 Future<void> refresh()async{setState(()=>future=Api(widget.token).get(widget.path));await future;}
 List<FieldSpec> fields(){
  if(widget.path.endsWith('/prospects'))return const [FieldSpec('lead_name','Prospect name','text',true),FieldSpec('company_name','Company','text'),FieldSpec('email','Email','email'),FieldSpec('phone','Phone','text'),FieldSpec('source','Source','text'),FieldSpec('stage','Stage','select:new|qualified|proposal|negotiation|won|lost'),FieldSpec('estimated_value_minor','Estimated value (minor units)','number'),FieldSpec('next_follow_up','Next follow-up','date'),FieldSpec('notes','Notes','text')];
  if(widget.path.endsWith('/signals'))return const [FieldSpec('company_name','Company','text',true),FieldSpec('signal_type','Signal type','select:hiring|expansion|new_location|technology_gap|service_problem|funding|contract_award|other',true),FieldSpec('summary','Evidence summary','text',true),FieldSpec('source_url','Evidence URL (HTTPS)','text'),FieldSpec('observed_at','Observed date','date')];
  if(widget.path.endsWith('/campaigns'))return const [FieldSpec('name','Campaign name','text',true),FieldSpec('audience_description','Target audience','text',true),FieldSpec('offer_summary','Offer summary','text',true)];
  if(widget.path.endsWith('/outbox'))return const [FieldSpec('lead_id','Prospect ID','text',true),FieldSpec('campaign_id','Campaign ID','text'),FieldSpec('evidence_signal_id','Evidence signal ID','text'),FieldSpec('to_email','Recipient email','email',true),FieldSpec('subject','Email subject','text',true),FieldSpec('body','Email draft body','text',true)];
  if(widget.path.endsWith('/replies'))return const [FieldSpec('from_email','Sender email','email',true),FieldSpec('lead_id','Prospect ID','text'),FieldSpec('body','Reply content','text',true)];
  if(widget.path.endsWith('/suppressions'))return const [FieldSpec('email','Email address','email',true),FieldSpec('reason','Reason','text')];
  return const [];
 }
 Future<void> create()async{
  final fs=fields();if(fs.isEmpty)return;
  final spec=ModuleSpec(widget.path,widget.title,'Sales Intelligence',fs);
  final body=await showDialog<Map<String,dynamic>>(context:context,builder:(_)=>RecordDialog(spec:spec));
  if(body==null)return;
  final endpoint=widget.path.endsWith('/outbox')?'/sales-intelligence/drafts':widget.path;
  setState(()=>busy=true);
  try{await Api(widget.token).post(endpoint,body);await refresh();if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Saved successfully.')));}
  catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
  finally{if(mounted)setState(()=>busy=false);}
 }
 Future<void> review(String id,String action)async{
  try{await Api(widget.token).post('/sales-intelligence/outbox/'+id+'/'+action,{});await refresh();if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(action=='approve'?'Draft approved for manual export.':'Draft rejected.')));}
  catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
 }
 @override Widget build(BuildContext context)=>Column(children:[
  Padding(padding:const EdgeInsets.all(20),child:Row(children:[Expanded(child:Text(widget.title,style:const TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:navy))),if(fields().isNotEmpty)FilledButton.icon(onPressed:busy?null:create,icon:const Icon(Icons.add),label:const Text('Add'))])),
  Expanded(child:FutureBuilder<Map<String,dynamic>>(future:future,builder:(c,s){
   if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
   if(s.hasError)return ErrorView(message:s.error.toString(),retry:refresh);
   final d=s.data??{};
   return RefreshIndicator(onRefresh:refresh,child:ListView(padding:const EdgeInsets.all(16),children:[
    for(final e in d.entries)if(e.value is num)Card(child:ListTile(title:Text(human(e.key)),trailing:Text(e.value.toString(),style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800,color:navy)))),
    for(final e in d.entries)if(e.value is List)...[
     Padding(padding:const EdgeInsets.fromLTRB(4,16,4,8),child:Text(human(e.key),style:const TextStyle(fontSize:17,fontWeight:FontWeight.w800,color:navy))),
     for(final row in (e.value as List).take(150))if(row is Map)Card(child:ListTile(
      title:Text((row['name']??row['company_name']??row['lead_name']??row['subject']??row['summary']??row['id']??'Record').toString()),
      subtitle:Text(row.entries.where((x)=>x.key!='id'&&x.value!=null).take(3).map((x)=>human(x.key)+': '+x.value.toString()).join(' • '),maxLines:2,overflow:TextOverflow.ellipsis),
      trailing:widget.path.endsWith('/outbox')&&row['status']=='draft'?PopupMenuButton<String>(onSelected:(v)=>review(row['id'].toString(),v),itemBuilder:(_)=>const [PopupMenuItem(value:'approve',child:Text('Approve for manual export')),PopupMenuItem(value:'reject',child:Text('Reject draft'))]):null,
     ))
    ],
    if(d.isEmpty)const Card(child:Padding(padding:EdgeInsets.all(18),child:Text('No sales intelligence data is available yet.'))),
    if(widget.path.endsWith('/outbox'))const Padding(padding:EdgeInsets.all(12),child:Text('Joe&dave does not send emails. Approved drafts are for manual export only.',style:TextStyle(color:Colors.blueGrey,fontSize:12)))
   ]));
  })),
 ]);
}

class Settings extends StatelessWidget{
 final Map<String,dynamic> profile;const Settings({super.key,required this.profile});
 @override Widget build(BuildContext context){final u=profile['user'] is Map?profile['user'] as Map:{};final b=profile['business'] is Map?profile['business'] as Map:{};return ListView(padding:const EdgeInsets.all(20),children:[
  const Text('Workspace settings',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:navy)),
  Card(child:Column(children:[
   ListTile(leading:const Icon(Icons.business_outlined,color:blue),title:const Text('Business workspace'),subtitle:Text((b['display_name']??b['legal_name']??'').toString())),
   const Divider(height:1),ListTile(leading:const Icon(Icons.email_outlined,color:blue),title:const Text('Signed-in account'),subtitle:Text((u['email']??'').toString())),
   const Divider(height:1),ListTile(leading:const Icon(Icons.verified_user_outlined,color:blue),title:const Text('Workspace role'),subtitle:Text((u['role']??'').toString())),
   const Divider(height:1),ListTile(leading:const Icon(Icons.currency_exchange_outlined,color:blue),title:const Text('Currency'),subtitle:Text((b['currency_code']??'NGN').toString()))
  ])),
  const Card(child:Padding(padding:EdgeInsets.all(16),child:Text('Financial, HR and operational permissions are enforced by the server using your workspace role. Payroll and other restricted records remain protected by backend authorization.')))
 ]);}
}
class ErrorView extends StatelessWidget{
 final String message;final Future<void> Function() retry;const ErrorView({super.key,required this.message,required this.retry});
 @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(28),children:[const SizedBox(height:55),const Icon(Icons.cloud_off_outlined,size:50,color:Colors.blueGrey),const SizedBox(height:12),const Center(child:Text('Unable to load this workspace',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800,color:navy))),const SizedBox(height:8),Text(message,textAlign:TextAlign.center,style:const TextStyle(color:Colors.blueGrey)),const SizedBox(height:14),Center(child:OutlinedButton.icon(onPressed:retry,icon:const Icon(Icons.refresh),label:const Text('Try again')))]);
}
String human(String s)=>s.replaceAll('_',' ').split(' ').map((w)=>w.isEmpty?w:w[0].toUpperCase()+w.substring(1)).join(' ');


class BusinessSettingsPage extends StatefulWidget{
 final String token;const BusinessSettingsPage({super.key,required this.token});
 @override State<BusinessSettingsPage> createState()=>_BusinessSettingsPageState();
}
class _BusinessSettingsPageState extends State<BusinessSettingsPage>{
 final form=GlobalKey<FormState>();final fields=<String,TextEditingController>{};
 final picker=ImagePicker();bool loading=true,saving=false;String invoice='modern',receipt='classic',currency='NGN',brandColor='#245b3a',logo='';String? error;
 static const currencies=['NGN','USD','GBP','EUR','CAD','GHS','KES','ZAR'];
 @override void initState(){super.initState();for(final k in ['display_name','business_address','business_phone','business_email','tax_id'])fields[k]=TextEditingController();load();}
 Future<void> load()async{try{final d=await Api(widget.token).get('/business');if(!mounted)return;setState(() { for(final k in fields.keys) { fields[k]!.text=(d[k]??'').toString(); } currency=(d['currency_code']??'NGN').toString(); invoice=(d['invoice_template']??'modern').toString(); receipt=(d['receipt_template']??'classic').toString(); brandColor=(d['brand_color']??'#245b3a').toString(); logo=(d['logo_data_url']??'').toString(); loading=false; });}catch(e){if(mounted)setState(() { loading=false; error=e.toString(); });}}
 Future<void> pickLogo()async{try{final x=await picker.pickImage(source:ImageSource.gallery,imageQuality:75,maxWidth:900);if(x==null)return;final bytes=await x.readAsBytes();if(bytes.length>90000){setState(()=>error='Choose a logo image under 90 KB.');return;}final ext=x.name.toLowerCase().endsWith('.png')?'png':x.name.toLowerCase().endsWith('.webp')?'webp':'jpeg';setState(() { logo='data:image/'+ext+';base64,'+base64Encode(bytes); error=null; });}catch(e){setState(()=>error=e.toString());}}
 Future<void> save()async{if(!form.currentState!.validate())return;setState(() { saving=true; error=null; });try{await Api(widget.token).put('/business',{'display_name':fields['display_name']!.text.trim(),'business_address':fields['business_address']!.text.trim(),'business_phone':fields['business_phone']!.text.trim(),'business_email':fields['business_email']!.text.trim(),'tax_id':fields['tax_id']!.text.trim(),'currency_code':currency,'invoice_template':invoice,'receipt_template':receipt,'brand_color':brandColor,'logo_data_url':logo});if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Business profile saved.')));}catch(e){setState(()=>error=e.toString());}finally{if(mounted)setState(()=>saving=false);}}
 @override void dispose(){for(final c in fields.values)c.dispose();super.dispose();}
 @override Widget build(BuildContext context){if(loading)return const Center(child:CircularProgressIndicator());return ListView(padding:const EdgeInsets.all(20),children:[
  const Text('Business profile & branding',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:navy)),
  const Text('These details appear on business documents and workspace identity.',style:TextStyle(color:Colors.blueGrey)),
  const SizedBox(height:16),Form(key:form,child:Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[
   TextFormField(controller:fields['display_name'],decoration:const InputDecoration(labelText:'Business display name'),validator:(v)=>v==null||v.trim().isEmpty?'Business name is required.':null),
   const SizedBox(height:10),TextFormField(controller:fields['business_address'],decoration:const InputDecoration(labelText:'Business address')),
   const SizedBox(height:10),TextFormField(controller:fields['business_phone'],decoration:const InputDecoration(labelText:'Business phone'),keyboardType:TextInputType.phone),
   const SizedBox(height:10),TextFormField(controller:fields['business_email'],decoration:const InputDecoration(labelText:'Business email'),keyboardType:TextInputType.emailAddress),
   const SizedBox(height:10),TextFormField(controller:fields['tax_id'],decoration:const InputDecoration(labelText:'Tax / registration ID')),
   const SizedBox(height:12),DropdownButtonFormField<String>(value:currency,decoration:const InputDecoration(labelText:'Base currency'),items:[for(final c in currencies)DropdownMenuItem(value:c,child:Text(c))],onChanged:(v)=>setState(()=>currency=v??currency)),
   const SizedBox(height:12),DropdownButtonFormField<String>(value:invoice,decoration:const InputDecoration(labelText:'Invoice design'),items:const [DropdownMenuItem(value:'modern',child:Text('Modern')),DropdownMenuItem(value:'classic',child:Text('Classic')),DropdownMenuItem(value:'minimal',child:Text('Minimal'))],onChanged:(v)=>setState(()=>invoice=v??invoice)),
   const SizedBox(height:12),DropdownButtonFormField<String>(value:receipt,decoration:const InputDecoration(labelText:'Receipt design'),items:const [DropdownMenuItem(value:'classic',child:Text('Classic')),DropdownMenuItem(value:'modern',child:Text('Modern')),DropdownMenuItem(value:'minimal',child:Text('Minimal'))],onChanged:(v)=>setState(()=>receipt=v??receipt)),
   const SizedBox(height:16),Row(children:[if(logo.isNotEmpty)Container(width:64,height:64,padding:const EdgeInsets.all(4),decoration:BoxDecoration(border:Border.all(color:const Color(0xFFE0E7F0)),borderRadius:BorderRadius.circular(12)),child:Image.memory(base64Decode(logo.split(',').last),fit:BoxFit.contain)),const SizedBox(width:10),Expanded(child:OutlinedButton.icon(onPressed:pickLogo,icon:const Icon(Icons.image_outlined),label:const Text('Choose business logo')))]),
   if(error!=null)Padding(padding:const EdgeInsets.only(top:12),child:Text(error!,style:const TextStyle(color:Colors.red))),
   const SizedBox(height:16),SizedBox(width:double.infinity,child:FilledButton(onPressed:saving?null:save,style:FilledButton.styleFrom(backgroundColor:blue),child:saving?const CircularProgressIndicator(color:Colors.white):const Text('Save business profile')))
  ]))))
 ]);}
}

class TeamMembersPage extends StatefulWidget{
 final String token;const TeamMembersPage({super.key,required this.token});
 @override State<TeamMembersPage> createState()=>_TeamMembersPageState();
}
class _TeamMembersPageState extends State<TeamMembersPage>{
 late Future<Map<String,dynamic>> future;final email=TextEditingController();String role='sales';bool adding=false;
 @override void initState(){super.initState();future=Api(widget.token).get('/workspace/members');}
 Future<void> refresh()async{setState(()=>future=Api(widget.token).get('/workspace/members'));await future;}
 Future<void> add()async{if(email.text.trim().isEmpty)return;setState(()=>adding=true);try{await Api(widget.token).post('/workspace/members',{'email':email.text.trim(),'role':role});email.clear();await refresh();if(mounted)ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Team member added.')));}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}finally{if(mounted)setState(()=>adding=false);}}
 Future<void> remove(String id)async{try{await Api(widget.token).delete('/workspace/members/'+id);await refresh();}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}}
 @override void dispose(){email.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>FutureBuilder<Map<String,dynamic>>(future:future,builder:(c,s){if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());if(s.hasError)return ErrorView(message:s.error.toString(),retry:refresh);final d=s.data??{},members=(d['members'] as List? ??[]).whereType<Map>().toList();final canManage=['owner','admin'].contains(d['current_role']);return RefreshIndicator(onRefresh:refresh,child:ListView(padding:const EdgeInsets.all(18),children:[
  const Text('Team & permissions',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:navy)),
  const Text('Add existing Joe&dave accounts and assign least-privilege roles.',style:TextStyle(color:Colors.blueGrey)),
  if(canManage)Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(children:[
   TextField(controller:email,keyboardType:TextInputType.emailAddress,decoration:const InputDecoration(labelText:'Registered user email')),
   const SizedBox(height:10),DropdownButtonFormField<String>(value:role,decoration:const InputDecoration(labelText:'Workspace role'),items:const [DropdownMenuItem(value:'admin',child:Text('Administrator')),DropdownMenuItem(value:'accountant',child:Text('Accountant')),DropdownMenuItem(value:'sales',child:Text('Sales')),DropdownMenuItem(value:'inventory',child:Text('Inventory')),DropdownMenuItem(value:'hr',child:Text('HR')),DropdownMenuItem(value:'viewer',child:Text('Read-only viewer'))],onChanged:(v)=>setState(()=>role=v??role)),
   const SizedBox(height:10),SizedBox(width:double.infinity,child:FilledButton(onPressed:adding?null:add,child:adding?const CircularProgressIndicator(color:Colors.white):const Text('Add team member'))),
   const Text('The person must already have a Joe&dave account. Email invitations are not enabled.',style:TextStyle(fontSize:12,color:Colors.blueGrey))
  ]))),
  const SizedBox(height:10),Text('Workspace members ('+members.length.toString()+')',style:const TextStyle(fontWeight:FontWeight.w800,fontSize:17,color:navy)),
  for(final m in members)Card(child:ListTile(leading:const CircleAvatar(child:Icon(Icons.person_outline)),title:Text((m['email']??'').toString()),subtitle:Text((m['role']??'').toString()),trailing:(m['role']=='owner'||!canManage)?null:IconButton(onPressed:()=>remove(m['user_id'].toString()),icon:const Icon(Icons.person_remove_outlined,color:Colors.red))))
 ]));});
}

class InventoryImportPage extends StatefulWidget{
 final String token;const InventoryImportPage({super.key,required this.token});
 @override State<InventoryImportPage> createState()=>_InventoryImportPageState();
}
class _InventoryImportPageState extends State<InventoryImportPage>{
 final csv=TextEditingController(text:'sku,name,quantity,unit,warehouse,reorder_level,cost_minor,sale_price_minor\\nSKU-001,Sample item,10,pcs,Main,2,50000,75000');
 bool busy=false;String? result;
 List<String> parseCsvLine(String line){final out=<String>[];final b=StringBuffer();bool quoted=false;for(var i=0;i<line.length;i++){final ch=line[i];if(ch=='"'){if(quoted&&i+1<line.length&&line[i+1]=='"'){b.write('"');i++;}else{quoted=!quoted;}}else if(ch==','&&!quoted){out.add(b.toString().trim());b.clear();}else{b.write(ch);}}out.add(b.toString().trim());return out;}
 Future<void> importRows()async{
  final lines=csv.text.split(RegExp(r'\r?\n')).where((x)=>x.trim().isNotEmpty).toList();if(lines.length<2){setState(()=>result='Add a header row and at least one inventory row.');return;}
  final headers=parseCsvLine(lines.first).map((x)=>x.toLowerCase()).toList();final rows=<Map<String,dynamic>>[];
  for(final line in lines.skip(1)){final values=parseCsvLine(line);final row=<String,dynamic>{};for(var i=0;i<headers.length&&i<values.length;i++){final key=headers[i],v=values[i];if(v.isNotEmpty)row[key]=['quantity','qty','reorder_level','cost_minor','sale_price_minor'].contains(key)?num.tryParse(v)??v:v;}rows.add(row);}
  if(rows.length>500){setState(()=>result='Import is limited to 500 rows per batch.');return;}
  setState(() { busy=true; result=null; });try{final d=await Api(widget.token).post('/inventory/import',{'rows':rows});setState(()=>result='Successfully imported '+(d['imported']??rows.length).toString()+' inventory rows.');}catch(e){setState(()=>result=e.toString());}finally{setState(()=>busy=false);}
 }
 @override void dispose(){csv.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(20),children:[
  const Text('Inventory CSV import',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900,color:navy)),
  const Text('Import or update stock items in batches of up to 500 rows. Matching SKU values update existing items and create stock adjustments.',style:TextStyle(color:Colors.blueGrey)),
  const SizedBox(height:14),const Card(child:Padding(padding:EdgeInsets.all(14),child:Text('Required columns: name (or item_code) and quantity. Optional: sku, unit, warehouse, reorder_level, cost_minor, sale_price_minor. Amount fields are in minor currency units.'))),
  const SizedBox(height:12),TextField(controller:csv,minLines:12,maxLines:20,decoration:const InputDecoration(labelText:'Paste CSV data',alignLabelWithHint:true,border:OutlineInputBorder())),
  if(result!=null)Padding(padding:const EdgeInsets.symmetric(vertical:12),child:Text(result!,style:TextStyle(color:result!.startsWith('Successfully')?Colors.green:Colors.red))),
  const SizedBox(height:12),FilledButton.icon(onPressed:busy?null:importRows,icon:const Icon(Icons.file_upload_outlined),label:busy?const Text('Importing…'):const Text('Validate and import'))
 ]);
}
