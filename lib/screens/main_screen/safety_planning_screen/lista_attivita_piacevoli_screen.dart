import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/progress.dart';
import '../../../providers/questions.dart';
import '../../questions_screen/questions_screen.dart';

class ListaAttivitaPiacevoliScreen extends StatefulWidget {
  ListaAttivitaPiacevoliScreen({
    super.key,
  });

  @override
  _ListaAttivitaPiacevoliScreenState createState() =>
      _ListaAttivitaPiacevoliScreenState();
}

class _ListaAttivitaPiacevoliScreenState
    extends State<ListaAttivitaPiacevoliScreen> {
  @override
  Widget build(BuildContext context) {
    final pp = Provider.of<Progress>(context);

    final questions = Provider.of<Questions>(context, listen: false);
    final blocks = questions.blocks("MM_lista_attivita_piacevoli");

    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 80,
      //   title: Text(
      //     '',
      //     style: MindBloomingTextStyle.header2,
      //   ),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      //   centerTitle: true,
      // ),
      body: Column(
        children: [
          // Padding(
          //   padding: const EdgeInsets.only(left: 25, top: 25, right: 25),
          //   child: Text(
          //
          //     style: MindBloomingTextStyle.normal,
          //   ),
          // ),
          // const SizedBox(height: 10),
          Expanded(
            child: QuestionsScreen(
              // The third parameter, context, is used in screening
              onDone: (surveyName, blockName, _) {
                pp.addDoneBlock(
                  surveyName,
                  blockName,
                );
              },
              buttonText: "Indietro",
              surveyName: "MM_lista_attivita_piacevoli",
              blockName: blocks.entries.first.key,
              title: 'Lista Attività Piacevoli',
              subtitle: '',
              // '',
            ),
            // margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            // padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
            // decoration: BoxDecoration(
            //   color: MindBloomingColorScheme.tertiary,
            //   borderRadius: BorderRadius.circular(20),
            // ),
            // child: const SizedBox(
            //   height: 12,
            // ),

            //   child: StreamBuilder(
            //     stream: FirebaseFirestore.instance
            //         .collection('listaAttivitaPiacevoli')
            //         .where(
            //           "userId",
            //           isEqualTo: FirebaseAuth.instance.currentUser!.uid,
            //         )
            //         .orderBy('order', descending: false)
            //         .snapshots(),
            //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return const Center(child: CircularProgressIndicator());
            //       }

            //       docs = snapshot.data!.docs;

            //       final userId = user?.uid;
            //       final doc = FirebaseFirestore.instance
            //           .collection("listaAttivitaPiacevoli")
            //           .doc();

            //       if (docs.isEmpty) {
            //         doc.set(
            //           {
            //             "order": '0',
            //             "title": 'Dormire',
            //             "userId": userId,
            //             "diaryId": doc.id,
            //             "isSelected": false, // nuovo campo
            //           },
            //         );

            //         doc.set(
            //           {
            //             "order": '1',
            //             "title": 'Mangiare',
            //             "userId": userId,
            //             "diaryId": doc.id,
            //             "isSelected": false, // nuovo campo
            //           },
            //         );

            //         FirebaseFirestore.instance
            //             .collection("listaAttivitaPiacevoli")
            //             .doc()
            //             .set(
            //           {
            //             "order": '2',
            //             "title": 'Giocare',
            //             "userId": userId,
            //             "isSelected": false, // nuovo campo
            //           },
            //         );
            //       }

            //       return Padding(
            //         padding: const EdgeInsets.symmetric(horizontal: 20),
            //         child: ReorderableListView.builder(
            //           itemCount: docs.length,
            //           itemBuilder: (context, index) {
            //             final title = docs[index]['title'];
            //             // final userId = docs[index]['userId'];
            //             final attivitaPiacevoleId = docs[index].id;

            //             return Container(
            //               key: Key(attivitaPiacevoleId),
            //               margin: const EdgeInsets.only(top: 20),
            //               child: Material(
            //                 shape: RoundedRectangleBorder(
            //                   borderRadius: BorderRadius.circular(10),
            //                 ),
            //                 child: ListTile(
            //                   onTap: () {
            //                     FirebaseFirestore.instance
            //                         .collection("listaAttivitaPiacevoli")
            //                         .doc(docs[index].id)
            //                         .update({
            //                       'isSelected': !docs[index]['isSelected'],
            //                     });
            //                   },

            //                   leading: Text(
            //                     (index + 1).toString() + '.',
            //                     style: MindBloomingTextStyle.header3,
            //                   ),

            //                   // title: Text(title, style: MindBloomingTextStyle.header3),

            //                   title: Text(
            //                     title,
            //                     style: docs[index]['isSelected']
            //                         ? MindBloomingTextStyle.isSelectedStyle
            //                         : MindBloomingTextStyle.isNotSelectedStyle,
            //                   ),

            //                   trailing: Row(
            //                     mainAxisSize: MainAxisSize.min,
            //                     children: [
            //                       Icon(
            //                         docs[index]['isSelected']
            //                             ? Icons.check_circle
            //                             : Icons.circle,
            //                         color: docs[index]['isSelected']
            //                             ? Colors.green
            //                             : Colors.grey,
            //                       ),
            //                       const SizedBox(width: 15),
            //                       GestureDetector(
            //                         onTap: () {
            //                           QuickAlert.show(
            //                             context: context,
            //                             type: QuickAlertType.error,
            //                             showCancelBtn: true,
            //                             title: 'Elimina Nota',
            //                             text:
            //                                 'Sei sicuro di voler eliminare questo elemento dalla Lista?',
            //                             confirmBtnText: 'Elimina',
            //                             confirmBtnColor: Colors.red,
            //                             cancelBtnText: 'Annulla',
            //                             onConfirmBtnTap: () {
            //                               FirebaseFirestore.instance
            //                                   .collection(
            //                                     "listaAttivitaPiacevoli",
            //                                   )
            //                                   .doc(attivitaPiacevoleId)
            //                                   .delete();
            //                               Navigator.pop(context);
            //                               showToast(
            //                                 message:
            //                                     "Elemento eliminato con successo.",
            //                               );
            //                             },
            //                           );
            //                         },
            //                         child: const Icon(Icons.delete),
            //                       ),
            //                       const SizedBox(width: 15),
            //                     ],
            //                   ),
            //                 ),
            //               ),
            //             );
            //           },
            //           onReorder: (oldIndex, newIndex) {
            //             setState(() {
            //               if (oldIndex < newIndex) {
            //                 newIndex -= 1;
            //               }
            //               final DocumentSnapshot doc = docs.removeAt(oldIndex);
            //               docs.insert(newIndex, doc);
            //             });

            //             for (int i = 0; i < docs.length; i++) {
            //               FirebaseFirestore.instance
            //                   .collection("listaAttivitaPiacevoli")
            //                   .doc(docs[i].id)
            //                   .update({
            //                 'order': i,
            //               });
            //             }
            //           },
            //           proxyDecorator: (child, index, animation) {
            //             return AnimatedBuilder(
            //               animation: animation,
            //               builder: (context, child) => Transform.scale(
            //                 scale: Tween(begin: 1.0, end: 0.975)
            //                     .animate(animation)
            //                     .value,
            //                 child: Container(
            //                   decoration: BoxDecoration(
            //                     borderRadius: BorderRadius.circular(10),
            //                   ),
            //                   child: child,
            //                 ),
            //               ),
            //               child: child,
            //             );
            //           },
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     showDialog(
      //       context: context,
      //       builder: (context) {
      //         String newTitle = "";

      //         return AlertDialog(
      //           title: const Text('Aggiungi Attività Piacevole'),
      //           content: TextField(
      //             onChanged: (value) {
      //               newTitle = value;
      //             },
      //             maxLength: 30,
      //             decoration: const InputDecoration(
      //               hintText: "Inserisci il titolo dell'attività",
      //             ),
      //           ),
      //           actions: [
      //             TextButton(
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               },
      //               child: const Text('Annulla'),
      //             ),
      //             TextButton(
      //               onPressed: () {
      //                 if (newTitle.isNotEmpty) {
      //                   FirebaseFirestore.instance
      //                       .collection("listaAttivitaPiacevoli")
      //                       .add({
      //                     "userId": user?.uid,
      //                     "title": newTitle,
      //                     "order": docs.length,
      //                     "isSelected": true, // nuovo campo
      //                     "attivitaPiacevoleId": FirebaseFirestore.instance
      //                         .collection("listaAttivitaPiacevoli")
      //                         .doc()
      //                         .id,
      //                   });
      //                   Navigator.of(context).pop();
      //                 }
      //               },
      //               child: const Text('Aggiungi'),
      //             ),
      //           ],
      //         );
      //       },
      //     );
      //   },
      //   child: const Icon(
      //     Icons.add,
      //     color: Colors.white,
      //   ),
      // ),
    );
  }
}
