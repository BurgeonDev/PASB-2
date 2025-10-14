import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:open_filex/open_filex.dart';

Future<void> fillAndPrintPensionForm(Map<String, String> data) async {
  // Load the existing PDF from assets
  final ByteData bytes = await rootBundle.load(
    'assets/forms/2_F366_Claim_Form.pdf',
  );
  final List<int> pdfBytes = bytes.buffer.asUint8List();

  // Load the document
  final PdfDocument document = PdfDocument(inputBytes: pdfBytes);
  final PdfPage page = document.pages[0];
  final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 10);

  // Overlay text on PDF (adjust positions as needed)
  // Combine Army No, Rank, and Name in one line
  final String personalInfo =
      "${data['NO'] ?? ''} , ${data['rank'] ?? ''} , ${data['name'] ?? ''}";

  page.graphics.drawString(
    personalInfo,
    font,
    bounds: const Rect.fromLTWH(300, 180, 400, 20), // adjust x, y, width
  );

  page.graphics.drawString(
    "${data['regt'] ?? ''}",
    font,
    bounds: const Rect.fromLTWH(300, 213, 300, 20),
  );

  // Combine Date, Place, Cause of Death in one line
  final String deathInfo =
      "${data['date_of_death'] ?? ''}, "
      "${data['place_of_death'] ?? ''}, "
      "${data['cause_of_death'] ?? ''}";

  page.graphics.drawString(
    deathInfo,
    font,
    bounds: const Rect.fromLTWH(300, 250, 500, 20), // widen the width to fit
  );

  // page.graphics.drawString(
  //   "CNIC: ${data['cnic'] ?? ''}",
  //   font,
  //   bounds: const Rect.fromLTWH(300, 160, 300, 20),
  // );
  // page.graphics.drawString(
  //   "Village: ${data['village'] ?? ''}",
  //   font,
  //   bounds: const Rect.fromLTWH(300, 180, 300, 20),
  // );
  // page.graphics.drawString(
  //   "NOK: ${data['nok_name'] ?? ''}",
  //   font,
  //   bounds: const Rect.fromLTWH(300, 200, 300, 20),
  // );
  // page.graphics.drawString(
  //   "Relation: ${data['relation'] ?? ''}",
  //   font,
  //   bounds: const Rect.fromLTWH(300, 220, 300, 20),
  // );

  // Save the filled PDF to a temporary directory
  final Directory tempDir = await getTemporaryDirectory();
  final String filePath = '${tempDir.path}/filled_pension_form.pdf';
  final File file = File(filePath);
  await file.writeAsBytes(await document.save());
  document.dispose();

  // Open the saved PDF
  await OpenFilex.open(filePath);
}
