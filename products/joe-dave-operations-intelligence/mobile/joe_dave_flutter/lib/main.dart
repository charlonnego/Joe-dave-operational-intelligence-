import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'module_specs.dart';

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
    setState(() { busy=true; error=null; });
    try{
      final result=await Api().post(register?'/auth/register':'/auth/login',{
        'email':email.text.trim(),'password':password.text,
        if(register)'business_name':business.text.trim(),
        if(register)'display_name':business.text.trim(),'currency_code':'NGN'});
      final sessionToken=result['token'] as String; final me=await Api(sessionToken).get('/auth/me'); await widget.onSignedIn(sessionToken,me);
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
    TextButton(onPressed:busy?null:()=>setState(() { register=!register; error=null; }),child:Text(register?'Already have an account? Sign in':'Create a new business workspace'))
  ]))))));
}

class Home extends StatefulWidget {
 final String token; final Map<String,dynamic> profile; final Future<void> Function() onSignOut;
 const Home({super.key,required this.token,required this.profile,required this.onSignOut});
 @override State<Home> createState()=>_HomeState();
}
class _HomeState extends State<Home>{
 String selected='dashboard',group='Overview';
 @override Widget build(BuildContext context){
  ModuleSpec? spec;
  for(final m in moduleSpecs){if(m.key==selected){spec=m;break;}}
  return Scaffold(appBar:AppBar(title:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Joe&dave',style:TextStyle(fontWeight:FontWeight.w800)),Text(group,style:const TextStyle(fontSize:12,color:Colors.blueGrey))]),actions:[IconButton(onPressed:widget.onSignOut,icon:const Icon(Icons.logout))]),
   drawer:Drawer(child:SafeArea(child:ListView(children:[
    const ListTile(leading:CircleAvatar(backgroundColor:blue,child:Icon(Icons.insights,color:Colors.white)),title:Text('Joe&dave',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('Operations Intelligence')),
    ListTile(selected:selected=='dashboard',leading:const Icon(Icons.dashboard),title:const Text('Business overview'),onTap:(){setState((){selected='dashboard';group='Overview';});Navigator.pop(context);}),
    for(final entry in moduleGroups.entries)...[
     Padding(padding:const EdgeInsets.fromLTRB(16,18,12,6),child:Text(entry.key.toUpperCase(),style:const TextStyle(fontSize:11,fontWeight:FontWeight.w800,color:Colors.blueGrey))),
     for(final key in entry.value)
      ListTile(dense:true,selected:selected==key,leading:const Icon(Icons.circle_outlined,size:15),title:Text(moduleSpecs.firstWhere((m)=>m.key==key).title),onTap:(){setState((){selected=key;group=entry.key;});Navigator.pop(context);})
    ],
    ListTile(leading:const Icon(Icons.logout),title:const Text('Sign out'),onTap:widget.onSignOut)
   ]))),
   body:selected=='dashboard'?DashboardPage(token:widget.token,onOpen:(key,title){setState((){selected=key;group=title;});}):spec==null?const Center(child:Text('Unavailable')):ResourcePage(key:ValueKey(selected),token:widget.token,spec:spec));
 }
}

class DashboardPage extends StatefulWidget{
 final String token;final void Function(String,String) onOpen;
 const DashboardPage({super.key,required this.token,required this.onOpen});
 @override State<DashboardPage> createState()=>_DashboardPageState();
}
class _DashboardPageState extends State<DashboardPage>{
 late Future<Map<String,dynamic>> future;
 @override void initState(){super.initState();future=Api(widget.token).get('/ops/');}
 Future<void> reload()async{setState(()=>future=Api(widget.token).get('/ops/'));await future;}
 @override Widget build(BuildContext context)=>RefreshIndicator(onRefresh:reload,child:FutureBuilder<Map<String,dynamic>>(future:future,builder:(context,s){
  if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
  if(s.hasError)return ListView(padding:const EdgeInsets.all(24),children:[const SizedBox(height:70),Text(s.error.toString(),textAlign:TextAlign.center),TextButton(onPressed:reload,child:const Text('Retry'))]);
  final metrics=<Widget>[];
  void scan(dynamic v){if(v is Map){v.forEach((k,x){if(x is num)metrics.add(SizedBox(width:MediaQuery.of(context).size.width>600?180:(MediaQuery.of(context).size.width-46)/2,child:Card(child:Padding(padding:const EdgeInsets.all(14),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(k.toString().replaceAll('_',' '),style:const TextStyle(color:Colors.blueGrey,fontSize:12)),const SizedBox(height:7),Text(x.toString(),style:const TextStyle(fontSize:23,fontWeight:FontWeight.w800,color:ink))])))));else if(x is Map)scan(x);});}}
  scan(s.data??{});
  return ListView(padding:const EdgeInsets.all(18),children:[
   const Text('Business overview',style:TextStyle(fontSize:25,fontWeight:FontWeight.w800,color:ink)),
   const Text('Live figures from your authenticated workspace.',style:TextStyle(color:Colors.blueGrey)),
   const SizedBox(height:14),Wrap(spacing:10,runSpacing:10,children:metrics.take(12).toList()),
   const SizedBox(height:20),const Text('Operations modules',style:TextStyle(fontSize:18,fontWeight:FontWeight.w800)),
   for(final entry in moduleGroups.entries)Card(child:ExpansionTile(title:Text(entry.key,style:const TextStyle(fontWeight:FontWeight.w700)),children:[for(final key in entry.value)ListTile(title:Text(moduleSpecs.firstWhere((m)=>m.key==key).title),trailing:const Icon(Icons.chevron_right),onTap:()=>widget.onOpen(key,entry.key))])),
   const Card(child:Padding(padding:EdgeInsets.all(14),child:Text('Payroll calculations currently cover base salary only. Statutory deductions and local compliance must be independently validated before processing payroll.')))
  ]);
 }));
}

class ResourcePage extends StatefulWidget{
 final String token;final ModuleSpec spec;
 const ResourcePage({super.key,required this.token,required this.spec});
 @override State<ResourcePage> createState()=>_ResourcePageState();
}
class _ResourcePageState extends State<ResourcePage>{
 late Future<List<Map<String,dynamic>>> future;String query='';
 @override void initState(){super.initState();future=load();}
 Future<List<Map<String,dynamic>>> load()async{final d=await Api(widget.token).get(widget.spec.apiRoute??('/ops/'+widget.spec.key));final rows=d[widget.spec.collectionKey??'records']??d['records']??d['rows']??[];return rows is List?rows.whereType<Map>().map((x)=>Map<String,dynamic>.from(x)).toList():<Map<String,dynamic>>[];}
 Future<void> refresh()async{setState(()=>future=load());await future;}
 @override Widget build(BuildContext context)=>Column(children:[
  Padding(padding:const EdgeInsets.fromLTRB(16,16,16,8),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.spec.title,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800,color:ink)),Text(widget.spec.fields.length.toString()+' fields · live records',style:const TextStyle(color:Colors.blueGrey,fontSize:12))])),if(!widget.spec.readOnly)FilledButton.icon(onPressed:create,icon:const Icon(Icons.add),label:const Text('New'))])),
  Padding(padding:const EdgeInsets.symmetric(horizontal:16,vertical:6),child:TextField(onChanged:(v)=>setState(()=>query=v),decoration:const InputDecoration(prefixIcon:Icon(Icons.search),hintText:'Search records',isDense:true))),
  Expanded(child:RefreshIndicator(onRefresh:refresh,child:FutureBuilder<List<Map<String,dynamic>>>(future:future,builder:(context,s){
   if(s.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
   if(s.hasError)return ListView(padding:const EdgeInsets.all(24),children:[Text(s.error.toString(),textAlign:TextAlign.center),TextButton(onPressed:refresh,child:const Text('Retry'))]);
   final all=s.data??[];final rows=all.where((r)=>query.isEmpty||r.values.any((v)=>v!=null&&v.toString().toLowerCase().contains(query.toLowerCase()))).toList();
   if(rows.isEmpty)return ListView(children:[const SizedBox(height:90),const Icon(Icons.inbox_outlined,size:48,color:Colors.blueGrey),Text(all.isEmpty?'No records yet. Create the first record.':'No matching records.',textAlign:TextAlign.center)]);
   return ListView.builder(padding:const EdgeInsets.all(14),itemCount:rows.length,itemBuilder:(context,i)=>recordCard(rows[i]));
  })))
 ]);
 }
 Widget recordCard(Map<String,dynamic> row){
  final title=(row['name']??row['lead_name']??row['subject']??row['title']??row['item_code']??row['employee_number']??row['order_number']??row['quote_number']??row['request_number']??row['id']??'Record').toString();
  final status=(row['status']??row['stage']??'').toString();
  final details=widget.spec.fields.where((f)=>row[f.key]!=null).take(3).map((f)=>f.label+': '+row[f.key].toString()).join(' · ');
  return Card(margin:const EdgeInsets.only(bottom:10),child:Padding(padding:const EdgeInsets.all(12),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
   Row(children:[Expanded(child:Text(title,style:const TextStyle(fontWeight:FontWeight.w800,color:ink))),if(status.isNotEmpty)Text(status.replaceAll('_',' '),style:const TextStyle(color:blue,fontWeight:FontWeight.w700,fontSize:12))]),
   if(details.isNotEmpty)Padding(padding:const EdgeInsets.only(top:6),child:Text(details,maxLines:3,overflow:TextOverflow.ellipsis,style:const TextStyle(color:Colors.blueGrey,fontSize:12))),
   const SizedBox(height:8),Wrap(spacing:5,runSpacing:4,children:[TextButton(onPressed:()=>showDetails(row),child:const Text('Details')),...actions(row).map((a)=>TextButton(onPressed:()=>runAction(row,a),child:Text(a)))])
  ])));
 }
 List<String> actions(Map<String,dynamic> r){
  final k=widget.spec.key,s=(r['status']??r['stage']??'').toString(),a=<String>[];
  if(k=='selling/quotations'){if(s=='draft'||s=='sent')a.addAll(['Add quote line','Accept quote']);if(s=='accepted')a.add('Convert to order');}
  if(k=='buying/requests'){if(s=='draft'||s=='submitted')a.add('Add material line');if(s=='draft')a.add('Submit request');if(s=='submitted')a.addAll(['Approve request','Reject request']);}
  if(k=='buying/orders'){if(s=='draft'||s=='ordered')a.add('Add item line');if(s=='draft')a.add('Mark ordered');}
  if(k=='buying/receipts'&&s=='draft')a.add('Post receipt');
  if(k=='buying/invoices'&&s=='draft')a.add('3-way match');
  if(k=='inventory/counts'&&s!='approved')a.addAll(['Enter count','Approve count']);
  if(k=='manufacturing/boms'&&s!='obsolete')a.add('Add component');
  if(k=='manufacturing/orders'){if(s=='planned')a.add('Release / issue materials');if(s=='released'||s=='in_progress')a.add('Record output');}
  if(k=='hr/leave'&&s=='pending')a.addAll(['Approve leave','Reject leave']);
  if(k=='hr/claims'&&s=='submitted')a.addAll(['Approve claim','Reject claim']);if(k=='hr/claims'&&s=='approved')a.add('Mark claim paid');
  if(k=='hr/payroll'){if(s=='draft'||s=='calculated')a.add('Calculate');if(s=='calculated')a.addAll(['Approve payroll','Salary slips']);if(s=='approved')a.add('Mark payroll paid');}
  if(k=='projects/timesheets'&&s=='submitted')a.add('Approve time');if(k=='projects/timesheets'&&s=='approved')a.add('Create draft invoice');
  if(k=='projects/tasks'&&s!='done')a.addAll(['Add prerequisite','Complete task']);
  if(k=='support/tickets'&&s!='resolved'&&s!='closed')a.add('Resolve ticket');
  return a;
 }
 Future<void> create()async{
  final ctrls={for(final f in widget.spec.fields)f.key:TextEditingController()};
  final key=GlobalKey<FormState>();bool busy=false;
  await showModalBottomSheet(context:context,isScrollControlled:true,useSafeArea:true,showDragHandle:true,builder:(ctx)=>StatefulBuilder(builder:(ctx,setSheet)=>Padding(padding:EdgeInsets.fromLTRB(18,12,18,MediaQuery.of(ctx).viewInsets.bottom+16),child:Form(key:key,child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.stretch,children:[
   Text('New '+widget.spec.title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:12),
   Flexible(child:SingleChildScrollView(child:Column(children:[for(final f in widget.spec.fields)Padding(padding:const EdgeInsets.only(bottom:9),child:field(f,ctrls[f.key]!))]))),
   FilledButton(onPressed:busy?null:()async{if(!key.currentState!.validate())return;setSheet(()=>busy=true);final body=<String,dynamic>{};for(final f in widget.spec.fields){final v=ctrls[f.key]!.text.trim();if(v.isNotEmpty)body[f.key]=f.type=='number'?num.tryParse(v):v;}try{final out=await Api(widget.token).post(widget.spec.apiRoute??('/ops/'+widget.spec.key),body);if(ctx.mounted)Navigator.pop(ctx);await refresh();if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('Saved record '+(out['id']??'success').toString())));}catch(e){setSheet(()=>busy=false);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}},child:busy?const CircularProgressIndicator():const Text('Save record'))
  ]))));
  for(final c in ctrls.values){c.dispose();}
 }
 Widget field(FieldSpec f,TextEditingController c){
  if(f.type.startsWith('select:'))return DropdownButtonFormField<String>(decoration:InputDecoration(labelText:f.label),items:f.type.substring(7).split('|').map((v)=>DropdownMenuItem(value:v,child:Text(v.replaceAll('_',' ')))).toList(),onChanged:(v)=>c.text=v??'',validator:(v)=>f.required&&(v==null||v.isEmpty)?'Required':null);
  return TextFormField(controller:c,keyboardType:f.type=='number'?const TextInputType.numberWithOptions(decimal:true):f.type=='email'?TextInputType.emailAddress:TextInputType.text,maxLines:f.key.contains('description')||f.key=='notes'||f.key=='body'?3:1,decoration:InputDecoration(labelText:f.label),validator:(v)=>f.required&&(v==null||v.trim().isEmpty)?'Required':null);
 }
 void showDetails(Map<String,dynamic> row){showModalBottomSheet(context:context,isScrollControlled:true,showDragHandle:true,builder:(ctx)=>SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:SingleChildScrollView(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(widget.spec.title,style:const TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:12),for(final e in row.entries)Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[SizedBox(width:120,child:Text(e.key.replaceAll('_',' '),style:const TextStyle(color:Colors.blueGrey,fontSize:12))),Expanded(child:SelectableText(e.value?.toString()??'—'))]))]))));}
 Future<void> runAction(Map<String,dynamic> row,String label)async{
  final id=Uri.encodeComponent((row['id']??'').toString());if(id.isEmpty)return;
  String path='/ops/'+widget.spec.key+'/'+id,method='POST';Map<String,dynamic> body={};
  switch(label){
   case 'Mark ordered':path+='/order';break;
   case 'Approve time':path='/ops/projects/timesheets/'+id;method='PATCH';body={'status':'approved'};break;
   case 'Approve leave':case 'Reject leave':path='/ops/hr/leave/'+id;method='PATCH';body={'status':label=='Approve leave'?'approved':'rejected'};break;
   case 'Approve claim':case 'Reject claim':case 'Mark claim paid':path='/ops/hr/claims/'+id;method='PATCH';body={'status':label=='Approve claim'?'approved':label=='Reject claim'?'rejected':'paid'};break;
   case 'Submit request':case 'Approve request':case 'Reject request':path='/ops/buying/requests/'+id;method='PATCH';body={'status':label=='Submit request'?'submitted':label=='Approve request'?'approved':'rejected'};break;
   case 'Accept quote':path='/ops/selling/quotations/'+id+'/accept';break;
   case 'Convert to order':path='/ops/selling/quotations/'+id+'/convert';break;
   case 'Release / issue materials':path='/ops/manufacturing/orders/'+id+'/release';break;
   case 'Record output':final q=await askValue('Quantity produced');if(q==null)return;path='/ops/manufacturing/orders/'+id+'/complete';body={'produced_quantity':num.tryParse(q)??0};break;
   case 'Approve payroll':path='/ops/hr/payroll/'+id;method='PATCH';body={'status':'approved'};break;
   case 'Mark payroll paid':path='/ops/hr/payroll/'+id;method='PATCH';body={'status':'paid'};break;
   case 'Salary slips':path='/ops/hr/payroll/'+id+'/lines';break;
   case 'Create draft invoice':path='/ops/projects/timesheets/'+id+'/bill';break;
   case 'Complete task':path='/ops/projects/tasks/'+id+'/complete';break;
   case 'Resolve ticket':path='/ops/support/tickets/'+id+'/resolve';break;
   case '3-way match':path='/ops/buying/invoices/'+id+'/match';break;
   case 'Post receipt':path='/ops/buying/receipts/'+id+'/post';break;
   case 'Approve count':path='/ops/inventory/counts/'+id+'/approve';break;
   case 'Add quote line':final v_quote=await askFields('Quotation line',['description','quantity','unit_price_minor','tax_rate','item_id']);if(v_quote==null)return;path='/ops/selling/quotations/'+id+'/lines';body={'description':v_quote['description'],'quantity':num.tryParse(v_quote['quantity']??'1')??1,'unit_price_minor':num.tryParse(v_quote['unit_price_minor']??'0')??0,'tax_rate':num.tryParse(v_quote['tax_rate']??'0')??0,'item_id':(v_quote['item_id']??'').isEmpty?null:v_quote['item_id']};break;
   case 'Add material line':final v_material=await askFields('Material request line',['description','quantity','item_id','warehouse_id']);if(v_material==null)return;path='/ops/buying/requests/'+id+'/lines';body={'description':v_material['description'],'quantity':num.tryParse(v_material['quantity']??'1')??1,'item_id':(v_material['item_id']??'').isEmpty?null:v_material['item_id'],'warehouse_id':(v_material['warehouse_id']??'').isEmpty?null:v_material['warehouse_id']};break;
   case 'Add item line':final v_po=await askFields('Purchase order line',['item_id','quantity_ordered','unit_cost_minor']);if(v_po==null)return;path='/ops/buying/orders/'+id+'/lines';body={'item_id':v_po['item_id'],'description':'Item '+(v_po['item_id']??''),'quantity_ordered':num.tryParse(v_po['quantity_ordered']??'1')??1,'unit_cost_minor':num.tryParse(v_po['unit_cost_minor']??'0')??0};break;
   case 'Enter count':final v_count=await askFields('Physical stock count',['item_id','counted_quantity']);if(v_count==null)return;path='/ops/inventory/counts/'+id+'/lines';body={'item_id':v_count['item_id'],'counted_quantity':num.tryParse(v_count['counted_quantity']??'0')??0};break;
   case 'Add component':final v_component=await askFields('BOM component',['component_item_id','quantity_per_output']);if(v_component==null)return;path='/ops/manufacturing/boms/'+id+'/lines';body={'lines':[{'component_item_id':v_component['component_item_id'],'quantity_per_output':num.tryParse(v_component['quantity_per_output']??'1')??1}]};break;
   case 'Add prerequisite':final v_dependency=await askFields('Task prerequisite',['depends_on_task_id']);if(v_dependency==null)return;path='/ops/projects/tasks/'+id+'/dependencies';body={'depends_on_task_id':v_dependency['depends_on_task_id']};break;
  }
  try{final result=method=='PATCH'?await patch(path,body):await Api(widget.token).post(path,body);if(label=='Salary slips'&&mounted){final lines=result['lines']??[];showDialog(context:context,builder:(ctx)=>AlertDialog(title:const Text('Salary slips'),content:SingleChildScrollView(child:Text(lines.map((x)=>x.toString()).join('\n'))),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Close'))]));}else{if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(label+' completed')));await refresh();}}catch(e){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(e.toString())));}
 }
 Future<Map<String,dynamic>> patch(String path,Map<String,dynamic> body)async{final r=await http.patch(Uri.parse(apiRoot+path),headers:{'Accept':'application/json','Content-Type':'application/json','Authorization':'Bearer '+widget.token},body:jsonEncode(body));final d=jsonDecode(r.body);if(r.statusCode<200||r.statusCode>=300)throw Exception(d['error']??'Request failed');return Map<String,dynamic>.from(d);}
 Future<Map<String,String>?> askFields(String title,List<String> names)async{
  final controllers={for(final n in names)n:TextEditingController()};
  final result=await showDialog<Map<String,String>>(context:context,builder:(ctx)=>AlertDialog(title:Text(title),content:SingleChildScrollView(child:Column(mainAxisSize:MainAxisSize.min,children:[for(final n in names)Padding(padding:const EdgeInsets.only(bottom:8),child:TextField(controller:controllers[n],decoration:InputDecoration(labelText:n.replaceAll('_',' '))))])),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,{for(final n in names)n:controllers[n]!.text.trim()}),child:const Text('Save line'))]));
  for(final x in controllers.values){x.dispose();}
  if(result!=null&&names.any((n)=>(result[n]??'').isEmpty))return null;
  return result;
 }
 Future<String?> askValue(String title)async{final c=TextEditingController();return showDialog<String>(context:context,builder:(ctx)=>AlertDialog(title:Text(title),content:TextField(controller:c,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Quantity')),actions:[TextButton(onPressed:()=>Navigator.pop(ctx),child:const Text('Cancel')),FilledButton(onPressed:()=>Navigator.pop(ctx,c.text),child:const Text('Continue'))]));}
}
