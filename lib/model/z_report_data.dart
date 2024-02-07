class TemplateZReport {
  final String generatedDate;
  final String reportDate;
  final TemplateSalesSummary salesSummary;
  final TemplateBrandSummary brandSummary;
  final TemplateItemSummary itemSummary;
  final TemplateItemSummary modifierItemSummary;
  final TemplatePaymentMethodSummary paymentMethodSummary;
  final TemplatePaymentChannelSummary paymentChannelSummary;

  TemplateZReport({
    required this.generatedDate,
    required this.reportDate,
    required this.salesSummary,
    required this.brandSummary,
    required this.itemSummary,
    required this.modifierItemSummary,
    required this.paymentMethodSummary,
    required this.paymentChannelSummary,
  });
}

class TemplateSalesSummary {
  final String totalSales;
  final String discount;
  final String netSales;
  final List<TemplateSummaryItem> summaries;

  TemplateSalesSummary({
    required this.totalSales,
    required this.discount,
    required this.netSales,
    required this.summaries,
  });
}

class TemplateBrandSummary {
  final String totalSales;
  final String discount;
  final String netSales;
  final List<TemplateSummaryItem> summaries;

  TemplateBrandSummary({
    required this.totalSales,
    required this.discount,
    required this.netSales,
    required this.summaries,
  });
}

class TemplateItemSummary {
  final String totalSales;
  final List<TemplateSummaryItem> summaries;

  TemplateItemSummary({
    required this.totalSales,
    required this.summaries,
  });
}

class TemplatePaymentMethodSummary {
  final String totalSales;
  final String discount;
  final String netSales;
  final List<TemplateSummaryItem> summaries;

  TemplatePaymentMethodSummary({
    required this.totalSales,
    required this.discount,
    required this.netSales,
    required this.summaries,
  });
}

class TemplatePaymentChannelSummary {
  final String totalSales;
  final String discount;
  final String netSales;
  final List<TemplateSummaryItem> summaries;

  TemplatePaymentChannelSummary({
    required this.totalSales,
    required this.discount,
    required this.netSales,
    required this.summaries,
  });
}

class TemplateSummaryItem {
  final String name;
  final int quantity;
  final String amount;

  TemplateSummaryItem({
    required this.name,
    this.quantity = 1,
    required this.amount,
  });
}
