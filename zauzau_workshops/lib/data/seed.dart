import '../models/workshop.dart';

List<String> _people(int n) => List.generate(n, (i) => 'Guest ${i + 1}');


List<Workshop> seedWorkshops() {
  final now = DateTime.now();
  DateTime at(int days, int hour) =>
      DateTime(now.year, now.month, now.day + days, hour);

  return [
  
    Workshop(
      id: 's1',
      title: 'Wedding Cake Masterclass: Tiers, Fillings and Buttercream #1',
      category: WorkshopCategory.cakes,
      when: at(3, 11),
      limit: 12,
      place: 'Zau Zau, main kitchen',
      description: 'Build and decorate a three-tier cake from scratch.',
      names: _people(5),
    ),
   
    Workshop(
      id: 's2',
      title: 'Macaron Basics',
      category: WorkshopCategory.cookies,
      when: at(5, 15),
      limit: 6,
      place: 'Zau Zau, main kitchen',
      description: 'Shells, ganache and how not to crack them.',
      names: _people(6),
    ),
  
    Workshop(
      id: 's3',
      title: 'Sourdough for Beginners',
      category: WorkshopCategory.bread,
      when: at(-4, 12),
      limit: 10,
      place: 'Zau Zau, main kitchen',
      description: 'Starter care, folding and baking in a home oven.',
      names: _people(10),
    ),
    Workshop(
      id: 's4',
      title: 'Home Baking Q&A: Nutrition and Calories',
      category: WorkshopCategory.desserts,
      when: at(2, 19),
      limit: 100,
      place: 'https://meet.example.com/zauzau-qa',
      online: true,
      description: 'How to calculate calories and macros for your bakes.',
      names: _people(24),
    ),
    Workshop(
      id: 's5',
      title: 'Croissants from Scratch',
      category: WorkshopCategory.bread,
      when: at(1, 10),
      limit: 8,
      place: 'Zau Zau, main kitchen',
      description: 'Laminated dough, shaping and proofing.',
      names: _people(5),
    ),
    Workshop(
      id: 's6',
      title: 'Latte Art Evening',
      category: WorkshopCategory.drinks,
      when: at(7, 18),
      limit: 10,
      place: 'Zau Zau, coffee bar',
      names: _people(4),
    ),
    Workshop(
      id: 's7',
      title: 'Chocolate Truffles',
      category: WorkshopCategory.desserts,
      when: at(9, 16),
      limit: 12,
      place: 'Zau Zau, main kitchen',
      description: 'Tempering, ganache and hand-rolled coatings.',
      names: _people(7),
    ),
    Workshop(
      id: 's8',
      title: 'Kids Cupcake Party',
      category: WorkshopCategory.cakes,
      when: at(12, 12),
      limit: 15,
      place: 'Zau Zau, hall',
      description: 'Decorating cupcakes for children aged 6–10.',
      names: _people(13),
    ),
    Workshop(
      id: 's9',
      title: 'Gingerbread Cookies',
      category: WorkshopCategory.cookies,
      when: at(-10, 14),
      limit: 12,
      place: 'Zau Zau, hall',
      names: _people(9),
    ),
    Workshop(
      id: 's10',
      title: 'Cheesecake Without an Oven',
      category: WorkshopCategory.desserts,
      when: at(4, 17),
      limit: 14,
      place: 'Zau Zau, main kitchen',
      description: 'No-bake base, cream cheese filling and glaze.',
      names: _people(9),
    ),
    Workshop(
      id: 's11',
      title: 'Eclairs and Choux Pastry',
      category: WorkshopCategory.desserts,
      when: at(6, 11),
      limit: 8,
      place: 'Zau Zau, main kitchen',
      description: 'Dough, piping and three kinds of cream.',
      names: _people(6),
    ),
    Workshop(
      id: 's12',
      title: 'Specialty Coffee Tasting',
      category: WorkshopCategory.drinks,
      when: at(14, 18),
      limit: 20,
      place: 'Zau Zau, coffee bar',
      names: _people(6),
    ),
  ];
}
