class ChecklistItem {
  final String id;
  final String category;
  final String subcategory;
  final String label;
  final int marks;

  const ChecklistItem({
    required this.id,
    required this.category,
    required this.subcategory,
    required this.label,
    required this.marks,
  });
}

const List<ChecklistItem> allChecklistItems = [

  // ── A. FAECAL SLUDGE MANAGEMENT (80 marks) ──
  ChecklistItem(id:'A1', category:'A. Faecal Sludge Management', subcategory:'Infrastructure',
    label:'Flush/pour-flush toilets available with adequate coverage (all rooms & common areas)', marks:8),
  ChecklistItem(id:'A2', category:'A. Faecal Sludge Management', subcategory:'Infrastructure',
    label:'Functional toilets for men, women & differently-abled --- regularly cleaned & odourless', marks:8),
  ChecklistItem(id:'A3', category:'A. Faecal Sludge Management', subcategory:'Infrastructure',
    label:'Watertight septic tank with baffles connected to dedicated soak pit (IS:2470)', marks:22),
  ChecklistItem(id:'A4', category:'A. Faecal Sludge Management', subcategory:'Infrastructure',
    label:'Mechanical desludging of septic tank done regularly as per standards', marks:10),
  ChecklistItem(id:'A5', category:'A. Faecal Sludge Management', subcategory:'Practices',
    label:'Septic tank effluent NOT discharged to open drains --- periodic cleaning maintained', marks:8),
  ChecklistItem(id:'A6', category:'A. Faecal Sludge Management', subcategory:'Awareness Generation',
    label:'Awareness posters on sanitation & toilet hygiene visible on premises', marks:8),
  ChecklistItem(id:'A7', category:'A. Faecal Sludge Management', subcategory:'Innovations',
    label:'Innovative toilet or septic system (disaster resilient, space-saving, low-water flush)', marks:16),

  // ── B. SOLID WASTE MANAGEMENT (80 marks) ──
  ChecklistItem(id:'B1', category:'B. Solid Waste Management', subcategory:'Infrastructure',
    label:'Blue & green segregation bins in all rooms, public spaces, parking & staff quarters', marks:18),
  ChecklistItem(id:'B2', category:'B. Solid Waste Management', subcategory:'Infrastructure',
    label:'Biodegradable waste composting unit (drum composter / NADEP / biogas) on premises', marks:10),
  ChecklistItem(id:'B3', category:'B. Solid Waste Management', subcategory:'Infrastructure',
    label:'Separate bin and incinerator (or linkage) for menstrual/sanitary waste disposal', marks:6),
  ChecklistItem(id:'B4', category:'B. Solid Waste Management', subcategory:'Infrastructure',
    label:'Plastic waste segregated and sent to PWMU / cement factory / sustainable linkage', marks:8),
  ChecklistItem(id:'B5', category:'B. Solid Waste Management', subcategory:'Infrastructure',
    label:'Linkage with e-waste processing unit and large waste processing facility', marks:6),
  ChecklistItem(id:'B6', category:'B. Solid Waste Management', subcategory:'Practices',
    label:'No indiscriminate dumping or burning of waste; GP user charges payment up to date', marks:4),
  ChecklistItem(id:'B7', category:'B. Solid Waste Management', subcategory:'Practices',
    label:'Alternatives to single-use plastics promoted (glass bottles, reusable items)', marks:4),
  ChecklistItem(id:'B8', category:'B. Solid Waste Management', subcategory:'Awareness Generation',
    label:'Awareness posters on waste segregation, no plastic, safe menstrual hygiene visible', marks:8),
  ChecklistItem(id:'B9', category:'B. Solid Waste Management', subcategory:'Innovations',
    label:'Unique innovative solid waste practice (biodegradable treatment, plastic alternatives)', marks:16),

  // ── C. GREY WATER MANAGEMENT (40 marks) ──
  ChecklistItem(id:'C1', category:'C. Grey Water Management', subcategory:'Infrastructure',
    label:'Soak pit / leach pit / kitchen garden constructed for greywater disposal', marks:16),
  ChecklistItem(id:'C2', category:'C. Grey Water Management', subcategory:'Infrastructure',
    label:'Drainage / rainwater harvesting / pump to prevent waterlogging', marks:8),
  ChecklistItem(id:'C3', category:'C. Grey Water Management', subcategory:'Practices',
    label:'Greywater NOT mixed with blackwater (except in piped sewer systems)', marks:2),
  ChecklistItem(id:'C4', category:'C. Grey Water Management', subcategory:'Practices',
    label:'Treated wastewater recycled for landscaping or flushing (non-potable reuse)', marks:2),
  ChecklistItem(id:'C5', category:'C. Grey Water Management', subcategory:'Awareness Generation',
    label:'Posters on water conservation, towel reuse, and greywater recharge visible', marks:4),
  ChecklistItem(id:'C6', category:'C. Grey Water Management', subcategory:'Innovations',
    label:'Innovative greywater management (ZLD, treated reuse system, water recycling)', marks:8),
];

Map<String, List<ChecklistItem>> get itemsByCategory {
  final Map<String, List<ChecklistItem>> grouped = {};
  for (final item in allChecklistItems) {
    grouped.putIfAbsent(item.category, () => []).add(item);
  }
  return grouped;
}

int maxMarksForCategory(String category) =>
  allChecklistItems.where((i) => i.category == category)
  .fold(0, (sum, i) => sum + i.marks);