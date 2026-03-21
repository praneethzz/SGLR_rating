import '../models/resort.dart';

const List<Resort> allResorts = [

  // ── KATARI PALEM ──
  Resort(id:1, name:'Sun Rise', ownerName:'Sridhar', phone:'9951651139', area:'Katari Palem', roomCount:5),
  Resort(id:2, name:'Seagul', ownerName:'Satyanarayan', phone:'9121838043', area:'Katari Palem', roomCount:21),
  Resort(id:3, name:'Sea Dreams', ownerName:'Suresh', phone:'8309294686', area:'Katari Palem', roomCount:8),
  Resort(id:4, name:'Natural', ownerName:'Pruthvi', phone:'9246570805', area:'Katari Palem', roomCount:7),
  Resort(id:5, name:'ALA', ownerName:'Sai', phone:'7013448125', area:'Katari Palem', roomCount:36),
  Resort(id:6, name:'Golden Swan', ownerName:'Balu', phone:'8125763362', area:'Katari Palem', roomCount:16),
  Resort(id:7, name:'Mahromi Villa', ownerName:'Pavan', phone:'8978038978', area:'Katari Palem', roomCount:3),
  Resort(id:8, name:'Blue Waves', ownerName:'Tulasi Ram', phone:'9701793181', area:'Katari Palem', roomCount:12),
  Resort(id:9, name:'Satya Grand', ownerName:'Trinadh', phone:'9962661157', area:'Katari Palem', roomCount:9),
  Resort(id:10, name:'Riviera Beach Resort', ownerName:'Govinda Reddy', phone:'7981198848', area:'Katari Palem', roomCount:59),
  Resort(id:39, name:'7 Star', ownerName:'K.Kalyan & A.Koteaswarao', phone:'9700660665', area:'Katari Palem', roomCount:20),
  Resort(id:40, name:'RB Resorts', ownerName:'Prathap', phone:'9992171112', area:'Katari Palem', roomCount:21),
  Resort(id:41, name:'Reboot', ownerName:'', phone:'7093040001', area:'Katari Palem', roomCount:0),

  // ── RAMAPURAM ──
  Resort(id:11, name:'Seabreeze', ownerName:'Dr Ravi Kiran', phone:'9949236660', area:'Ramapuram', roomCount:59),
  Resort(id:12, name:'Meghana', ownerName:'Sarath', phone:'9000168999', area:'Ramapuram', roomCount:15),
  Resort(id:13, name:'Royal', ownerName:'Kalyan', phone:'7013448009', area:'Ramapuram', roomCount:6),
  Resort(id:14, name:'B Square', ownerName:'Kiran', phone:'9885679913', area:'Ramapuram', roomCount:19),
  Resort(id:15, name:'Palm Coast', ownerName:'Dr Bhavani Prasad', phone:'9849046360', area:'Ramapuram', roomCount:25),
  Resort(id:16, name:'Pearl', ownerName:'Hari', phone:'7013636996', area:'Ramapuram', roomCount:20),
  Resort(id:17, name:'Raja', ownerName:'Rajasekhar', phone:'9346712148', area:'Ramapuram', roomCount:19),
  Resort(id:18, name:'Blue 6', ownerName:'Kalyan', phone:'7013448009', area:'Ramapuram', roomCount:8),
  Resort(id:19, name:'Happy Days', ownerName:'Venkatesh', phone:'8886665146', area:'Ramapuram', roomCount:15),
  Resort(id:20, name:'Aura', ownerName:'Naveen', phone:'9154339309', area:'Ramapuram', roomCount:2),
  Resort(id:21, name:'Beach Wind', ownerName:'S Veerabhadra Rao', phone:'9949255678', area:'Ramapuram', roomCount:11),
  Resort(id:22, name:'Moon Light', ownerName:'Bapuji', phone:'9848589393', area:'Ramapuram', roomCount:12),
  Resort(id:23, name:'Windy', ownerName:'Subhashini', phone:'9849335881', area:'Ramapuram', roomCount:4),
  Resort(id:24, name:'Rainbow', ownerName:'Narendra', phone:'9700864668', area:'Ramapuram', roomCount:24),
  Resort(id:25, name:'Grand Arya (U/C)', ownerName:'', phone:'', area:'Ramapuram', roomCount:0),
  Resort(id:26, name:'AK Grand', ownerName:'', phone:'9966777635', area:'Ramapuram', roomCount:8),
  Resort(id:37, name:'KJ Resort', ownerName:'K Jala Reddy', phone:'9182066946', area:'Ramapuram', roomCount:19),
  Resort(id:38, name:'Arna Beach Resort', ownerName:'G. Pradeep', phone:'9666746756', area:'Ramapuram', roomCount:10),

  // ── VODAREVU ──
  Resort(id:27, name:'Krishna Vamsi', ownerName:'Mahesh', phone:'8501091007', area:'Vodarevu', roomCount:10),
  Resort(id:28, name:'Royal Samudra', ownerName:'Anil Kumar', phone:'9390487001', area:'Vodarevu', roomCount:10),
  Resort(id:29, name:'Coastal Paradise', ownerName:'Buchi Babu', phone:'9010144937', area:'Vodarevu', roomCount:12),
  Resort(id:30, name:'Heritage', ownerName:'Bharadwaj', phone:'6301865272', area:'Vodarevu', roomCount:12),
  Resort(id:31, name:'Huts', ownerName:'S Veerabhadra Rao', phone:'9949255678', area:'Vodarevu', roomCount:20),
  Resort(id:32, name:'Dolphin GH', ownerName:'Neelakanth', phone:'9346256480', area:'Vodarevu', roomCount:5),
  Resort(id:33, name:'Tajj Grand', ownerName:'Nazeer', phone:'7382503810', area:'Vodarevu', roomCount:6),
  Resort(id:34, name:'JP Grand', ownerName:'Feroj', phone:'9346734992', area:'Vodarevu', roomCount:3),
  Resort(id:35, name:'Mastanreddy GH', ownerName:'Mastan', phone:'9100642100', area:'Vodarevu', roomCount:4),
  Resort(id:36, name:'Buddha (U/C)', ownerName:'', phone:'', area:'Vodarevu', roomCount:0),
];

Map<String, List<Resort>> get resortsByArea {
  final Map<String, List<Resort>> grouped = {};
  for (final resort in allResorts) {
    grouped.putIfAbsent(resort.area, () => []).add(resort);
  }
  return grouped;
}