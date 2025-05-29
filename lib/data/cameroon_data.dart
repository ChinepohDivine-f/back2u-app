import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:back2u/models/category_model.dart';
import 'package:back2u/models/location_model.dart';
import 'package:back2u/models/app_info_model.dart';
import 'package:back2u/models/country_model.dart'; // Import the new model
import 'package:uuid/uuid.dart';

class CameroonData {
  static final Uuid _uuid = Uuid();

  static AppInfo getAppInfoData() {
    return AppInfo(
      appVersion: "1.0.0",
      appNameEn: "Back2u",
      appNameFr: "Back2u",
      contactEmail: "support@back2u.com",
      privacyPolicyUrl: "https://www.back2u.com/privacy",
      termsOfServiceUrl: "https://www.back2u.com/terms",
      lastUpdated: Timestamp.now(),
    );
  }

  // New method to get Cameroon's country data
  static Country getCameroonCountryData() {
    return Country(
      id: 'cameroon', // Document ID will be 'cameroon'
      nameEn: 'Cameroon',
      nameFr: 'Cameroun',
      countryCode: 'CM',
      phoneCode: '+237',
      flagEmoji: '🇨🇲',
      currencyName: 'Central African CFA franc',
      currencyCode: 'XAF',
      capitalCityEn: 'Yaoundé',
      capitalCityFr: 'Yaoundé',
      officialLanguages: ['English', 'French'],
      region: 'Central Africa',
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );
  }

  static List<Category> getCategoriesData() {
    List<Category> categories = [];

    // Identification Documents
    String idCategoryId = _uuid.v4();
    categories.add(Category(
      categoryId: idCategoryId,
      createdAt: Timestamp.now(),
      nameEn: "Identification Documents",
      nameFr: "Documents d'Identité",
      subcategories: [
        SubCategory(
          categoryId: idCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Driver's License",
          nameFr: "Permis de Conduire",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: idCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "National Identity Card",
          nameFr: "Carte Nationale d'Identité",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: idCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Passport",
          nameFr: "Passeport",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: idCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Birth Certificate",
          nameFr: "Acte de Naissance",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: idCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Marriage Certificate",
          nameFr: "Acte de Mariage",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: idCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Death Certificate",
          nameFr: "Acte de Décès",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: idCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Voter's Card",
          nameFr: "Carte d'Électeur",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: idCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Consular Card",
          nameFr: "Carte Consulaire",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
      ],
      updatedAt: Timestamp.now(),
    ));

    // Vehicle Documents
    String vehicleCategoryId = _uuid.v4();
    categories.add(Category(
      categoryId: vehicleCategoryId,
      createdAt: Timestamp.now(),
      nameEn: "Vehicle Documents",
      nameFr: "Documents de Véhicule",
      subcategories: [
        SubCategory(
          categoryId: vehicleCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Car Registration (Carte Grise)",
          nameFr: "Carte Grise",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: vehicleCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Proof of Ownership/Change of Ownership",
          nameFr: "Preuve de Propriété/Changement de Propriété",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: vehicleCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Car Insurance",
          nameFr: "Assurance Automobile",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: vehicleCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Road Worthiness Report (Visite Technique)",
          nameFr: "Visite Technique",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: vehicleCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Motorcycle Insurance",
          nameFr: "Assurance Moto",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: vehicleCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Driving Permit",
          nameFr: "Autorisation de Conduire",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
      ],
      updatedAt: Timestamp.now(),
    ));

    // Educational Documents
    String eduCategoryId = _uuid.v4();
    categories.add(Category(
      categoryId: eduCategoryId,
      createdAt: Timestamp.now(),
      nameEn: "Educational Documents",
      nameFr: "Documents Éducatifs",
      subcategories: [
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "GCE O/L Certificate",
          nameFr: "Certificat GCE O/L",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "GCE A/L Certificate",
          nameFr: "Certificat GCE A/L",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "GCE Slip",
          nameFr: "Bordereau GCE",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "BAC",
          nameFr: "BAC",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "BEPC",
          nameFr: "BEPC",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "CAP",
          nameFr: "CAP",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "University Transcript",
          nameFr: "Relevé de Notes Universitaire",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "HND",
          nameFr: "HND",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Degree Certificate (License, Bachelor's)",
          nameFr: "Diplôme de Licence",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Masters Degree",
          nameFr: "Diplôme de Master",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "PhD Certificate",
          nameFr: "Diplôme de Doctorat",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "FSLC",
          nameFr: "FSLC",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: eduCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Professional Certificate",
          nameFr: "Certificat Professionnel",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
      ],
      updatedAt: Timestamp.now(),
    ));

    // Financial Documents
    String finCategoryId = _uuid.v4();
    categories.add(Category(
      categoryId: finCategoryId,
      createdAt: Timestamp.now(),
      nameEn: "Financial Documents",
      nameFr: "Documents Financiers",
      subcategories: [
        SubCategory(
          categoryId: finCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Bank Card",
          nameFr: "Carte Bancaire",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: finCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Tax Payers Card",
          nameFr: "Carte de Contribuable",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: finCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Life Insurance",
          nameFr: "Assurance Vie",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: finCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Property Tax",
          nameFr: "Impôt Foncier",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: finCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Bank Statement",
          nameFr: "Relevé Bancaire",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: finCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Pay Slip",
          nameFr: "Fiche de Paie",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: finCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Share Certificate",
          nameFr: "Certificat d'Actions",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
      ],
      updatedAt: Timestamp.now(),
    ));

    // Legal Documents
    String legalCategoryId = _uuid.v4();
    categories.add(Category(
      categoryId: legalCategoryId,
      createdAt: Timestamp.now(),
      nameEn: "Legal Documents",
      nameFr: "Documents Légaux",
      subcategories: [
        SubCategory(
          categoryId: legalCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Court Document",
          nameFr: "Document Judiciaire",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: legalCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Contract Agreement",
          nameFr: "Contrat d'Accord",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: legalCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Land Certificate (Titre Foncier)",
          nameFr: "Titre Foncier",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: legalCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Will",
          nameFr: "Testament",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: legalCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Power of Attorney",
          nameFr: "Procuration",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
      ],
      updatedAt: Timestamp.now(),
    ));

    // Other Documents
    String otherCategoryId = _uuid.v4();
    categories.add(Category(
      categoryId: otherCategoryId,
      createdAt: Timestamp.now(),
      nameEn: "Other Documents",
      nameFr: "Autres Documents",
      subcategories: [
        SubCategory(
          categoryId: otherCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Medical Prescription",
          nameFr: "Ordonnance Médicale",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: otherCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Property Deeds",
          nameFr: "Titres de Propriété",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
        SubCategory(
          categoryId: otherCategoryId,
          createdAt: Timestamp.now(),
          nameEn: "Business Registration",
          nameFr: "Registre de Commerce",
          subCategoryId: _uuid.v4(),
          updatedAt: Timestamp.now(),
        ),
      ],
      updatedAt: Timestamp.now(),
    ));

    return categories;
  }

  static List<Location> getCameroonLocations() {
    List<Location> regions = [];

    // ADAMAWA Region
    String adamawaId = _uuid.v4();
    regions.add(Location(
      createdAt: Timestamp.now(),
      locationId: adamawaId,
      nameEn: "Adamawa",
      nameFr: "Adamaoua",
      sublocations: [
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: adamawaId,
            nameEn: "Ngaoundéré",
            nameFr: "Ngaoundéré",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: adamawaId,
            nameEn: "Tibati",
            nameFr: "Tibati",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: adamawaId,
            nameEn: "Meiganga",
            nameFr: "Meiganga",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: adamawaId,
            nameEn: "Banyo",
            nameFr: "Banyo",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
      ],
      updatedAt: Timestamp.now(),
    ));

    // CENTRE Region
    String centreId = _uuid.v4();
    regions.add(Location(
      createdAt: Timestamp.now(),
      locationId: centreId,
      nameEn: "Centre",
      nameFr: "Centre",
      sublocations: [
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: centreId,
            nameEn: "Yaoundé",
            nameFr: "Yaoundé",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: centreId,
            nameEn: "Mbalmayo",
            nameFr: "Mbalmayo",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: centreId,
            nameEn: "Nkolafamba",
            nameFr: "Nkolafamba",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: centreId,
            nameEn: "Obala",
            nameFr: "Obala",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: centreId,
            nameEn: "Sangmélima",
            nameFr: "Sangmélima",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: centreId,
            nameEn: "Ebolowa",
            nameFr: "Ebolowa",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()), // Ebolowa is actually in South, moving for demo purposes if needed
      ],
      updatedAt: Timestamp.now(),
    ));

    // EAST Region
    String eastId = _uuid.v4();
    regions.add(Location(
      createdAt: Timestamp.now(),
      locationId: eastId,
      nameEn: "East",
      nameFr: "Est",
      sublocations: [
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: eastId,
            nameEn: "Bertoua",
            nameFr: "Bertoua",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: eastId,
            nameEn: "Batouri",
            nameFr: "Batouri",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: eastId,
            nameEn: "Garoua-Boulaï",
            nameFr: "Garoua-Boulaï",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
      ],
      updatedAt: Timestamp.now(),
    ));

    // FAR NORTH Region
    String farNorthId = _uuid.v4();
    regions.add(Location(
      createdAt: Timestamp.now(),
      locationId: farNorthId,
      nameEn: "Far North",
      nameFr: "Extrême-Nord",
      sublocations: [
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: farNorthId,
            nameEn: "Maroua",
            nameFr: "Maroua",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: farNorthId,
            nameEn: "Kousséri",
            nameFr: "Kousséri",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: farNorthId,
            nameEn: "Mokolo",
            nameFr: "Mokolo",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: farNorthId,
            nameEn: "Mora",
            nameFr: "Mora",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
      ],
      updatedAt: Timestamp.now(),
    ));

    // LITTORAL Region
    String littoralId = _uuid.v4();
    regions.add(Location(
      createdAt: Timestamp.now(),
      locationId: littoralId,
      nameEn: "Littoral",
      nameFr: "Littoral",
      sublocations: [
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: littoralId,
            nameEn: "Douala",
            nameFr: "Douala",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: littoralId,
            nameEn: "Edea",
            nameFr: "Edéa",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: littoralId,
            nameEn: "Nkongsamba",
            nameFr: "Nkongsamba",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: littoralId,
            nameEn: "Loum",
            nameFr: "Loum",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
      ],
      updatedAt: Timestamp.now(),
    ));

    // NORTH Region
    String northId = _uuid.v4();
    regions.add(Location(
      createdAt: Timestamp.now(),
      locationId: northId,
      nameEn: "North",
      nameFr: "Nord",
      sublocations: [
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: northId,
            nameEn: "Garoua",
            nameFr: "Garoua",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: northId,
            nameEn: "Poli",
            nameFr: "Poli",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: northId,
            nameEn: "Guider",
            nameFr: "Guider",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
      ],
      updatedAt: Timestamp.now(),
    ));

    // NORTHWEST Region
    String northWestId = _uuid.v4();
    regions.add(Location(
      createdAt: Timestamp.now(),
      locationId: northWestId,
      nameEn: "Northwest",
      nameFr: "Nord-Ouest",
      sublocations: [
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: northWestId,
            nameEn: "Bamenda",
            nameFr: "Bamenda",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: northWestId,
            nameEn: "Kumbo",
            nameFr: "Kumbo",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: northWestId,
            nameEn: "Ndop",
            nameFr: "Ndop",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: northWestId,
            nameEn: "Wum",
            nameFr: "Wum",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: northWestId,
            nameEn: "Bafut",
            nameFr: "Bafut",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
      ],
      updatedAt: Timestamp.now(),
    ));

    // SOUTH Region
    String southId = _uuid.v4();
    regions.add(Location(
      createdAt: Timestamp.now(),
      locationId: southId,
      nameEn: "South",
      nameFr: "Sud",
      sublocations: [
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: southId,
            nameEn: "Ebolowa",
            nameFr: "Ebolowa",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: southId,
            nameEn: "Kribi",
            nameFr: "Kribi",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: southId,
            nameEn: "Sangmélima",
            nameFr: "Sangmélima",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
      ],
      updatedAt: Timestamp.now(),
    ));

    // SOUTHWEST Region
    String southWestId = _uuid.v4();
    regions.add(Location(
      createdAt: Timestamp.now(),
      locationId: southWestId,
      nameEn: "Southwest",
      nameFr: "Sud-Ouest",
      sublocations: [
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: southWestId,
            nameEn: "Buea",
            nameFr: "Buea",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: southWestId,
            nameEn: "Limbe",
            nameFr: "Limbe",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: southWestId,
            nameEn: "Kumba",
            nameFr: "Kumba",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: southWestId,
            nameEn: "Mamfe",
            nameFr: "Mamfe",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: southWestId,
            nameEn: "Tiko",
            nameFr: "Tiko",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
      ],
      updatedAt: Timestamp.now(),
    ));

    // WEST Region
    String westId = _uuid.v4();
    regions.add(Location(
      createdAt: Timestamp.now(),
      locationId: westId,
      nameEn: "West",
      nameFr: "Ouest",
      sublocations: [
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: westId,
            nameEn: "Bafoussam",
            nameFr: "Bafoussam",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: westId,
            nameEn: "Dschang",
            nameFr: "Dschang",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: westId,
            nameEn: "Foumban",
            nameFr: "Foumban",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: westId,
            nameEn: "Mbouda",
            nameFr: "Mbouda",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: westId,
            nameEn: "Bandjoun",
            nameFr: "Bandjoun",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
        SubLocation(
            createdAt: Timestamp.now(),
            locationId: westId,
            nameEn: "Bafang",
            nameFr: "Bafang",
            subLocationId: _uuid.v4(),
            updatedAt: Timestamp.now()),
      ],
      updatedAt: Timestamp.now(),
    ));

    return regions;
  }
}