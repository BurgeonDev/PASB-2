// import 'dart:io';
// import 'package:html_to_pdf/html_to_pdf.dart';
// import 'package:path_provider/path_provider.dart';

// Future<String> generatePensionPdf(Map<String, String> data) async {
//   final htmlContent = """
//   <html>
//     <head>
//       <style>
//         body { font-family: Arial, sans-serif; font-size: 14px; }
//         h2 { text-align: center; }
//         table { width: 100%; border-collapse: collapse; margin-top: 20px; }
//         td, th { border: 1px solid #000; padding: 5px; }
//         .section { background: #f0f0f0; font-weight: bold; }
//       </style>
//     </head>
//     <body>
//       <h2>Pension Merger Form</h2>

//       <table>
//         <tr class="section"><td colspan="2">Particulars of Deceased</td></tr>
//         <tr><td>Army No</td><td>${data['army_no'] ?? ''}</td></tr>
//         <tr><td>Rank</td><td>${data['rank'] ?? ''}</td></tr>
//         <tr><td>Name</td><td>${data['name'] ?? ''}</td></tr>
//         <tr><td>Father Name</td><td>${data['father_name'] ?? ''}</td></tr>
//         <tr><td>Regt/Corps</td><td>${data['regt_corps'] ?? ''}</td></tr>
//         <tr><td>Date of Discharge</td><td>${data['date_of_discharge'] ?? ''}</td></tr>
//         <tr><td>Date of Death</td><td>${data['date_of_death'] ?? ''}</td></tr>
//         <tr><td>Place of Death</td><td>${data['place_of_death'] ?? ''}</td></tr>
//         <tr><td>Cause of Death</td><td>${data['cause_of_death'] ?? ''}</td></tr>
//       </table>

//       <table>
//         <tr class="section"><td colspan="2">Next of Kin (NOK) Details</td></tr>
//         <tr><td>Pension Type</td><td>${data['pension_type'] ?? ''}</td></tr>
//         <tr><td>NOK Name</td><td>${data['nok_name'] ?? ''}</td></tr>
//         <tr><td>Relation</td><td>${data['relation'] ?? ''}</td></tr>
//         <tr><td>Date of Birth</td><td>${data['dob'] ?? ''}</td></tr>
//         <tr><td>Next NOK Name</td><td>${data['next_nok_name'] ?? ''}</td></tr>
//       </table>

//       <table>
//         <tr class="section"><td colspan="2">Urdu Info</td></tr>
//         <tr><td>نام</td><td>${data['urdu_name'] ?? ''}</td></tr>
//         <tr><td>ولدیت</td><td>${data['urdu_father_name'] ?? ''}</td></tr>
//         <tr><td>نک نام</td><td>${data['urdu_nok_name'] ?? ''}</td></tr>
//       </table>

//     </body>
//   </html>
//   """;

//   final dir = await getTemporaryDirectory();

//   // Define print configuration
//   final printConfig = PrintPdfConfiguration(
//     pageSize: PdfPageSize.a4,
//     orientation: PdfPageOrientation.portrait,
//     marginTop: 20,
//     marginBottom: 20,
//     marginLeft: 20,
//     marginRight: 20,
//   );

//   final output = await HtmlToPdf.convertFromHtmlContent(
//     htmlContent: htmlContent,
//     baseUrl: dir.path,
//     fileName: 'pension_form.pdf',
//     printPdfConfiguration: printConfig, // <-- required now
//   );

//   return output.path;
// }
