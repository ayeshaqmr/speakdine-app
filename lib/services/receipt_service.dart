import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:speakdine_app/models/order_model.dart';
import 'package:intl/intl.dart';

class ReceiptService {
  static Future<void> generateAndPrintReceipt(OrderModel order) async {
    final pdf = pw.Document();

    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('SPEAK DINE',
                            style: pw.TextStyle(
                                fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
                        pw.Text('Receipt from Speak Dine', style: const pw.TextStyle(fontSize: 12)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Order ID:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(order.id ?? 'Pending...'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 10),

                // Order Details
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Customer:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(order.userName),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Date:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.Text(dateFormat.format(order.createdAt)),
                  ],
                ),
                pw.SizedBox(height: 20),

                // Items Table
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey300),
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Text('Item', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Text('Price', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
                      ],
                    ),
                    ...order.items.map((item) => pw.TableRow(
                      children: [
                        pw.Padding(padding: const pw.EdgeInsets.all(10), child: pw.Text(item.name)),
                        pw.Padding(
                            padding: const pw.EdgeInsets.all(10),
                            child: pw.Text('Rs. ${item.price.toStringAsFixed(0)}')),
                      ],
                    )),
                  ],
                ),

                pw.SizedBox(height: 20),

                // Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('Total Amount: ',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Rs. ${order.totalAmount.toStringAsFixed(0)}',
                        style: pw.TextStyle(
                            fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.orange800)),
                  ],
                ),

                pw.Spacer(),
                pw.Center(
                  child: pw.Text('Thank you for choosing SPEAK DINE!',
                      style: pw.TextStyle(fontStyle: pw.FontStyle.italic, color: PdfColors.grey)),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}