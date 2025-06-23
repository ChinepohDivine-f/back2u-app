import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  // English translations
  static const Map<String, dynamic> _localizedValues = {
    'en': {
      'appTitle': 'Back2U',
      'welcome': 'Welcome',
      'getStarted': 'Get Started',
      'howItWorks': 'How It Works',
      'connect': 'Connect',
      'signIn': 'Sign In',
      'signInWithGoogle': 'Sign in with Google',
      'signInAnonymously': 'Continue as Guest',
      'signInToViewKyc' : 'Sign In to view Kyc status',
      'completeKyc' : 'Complete KYC',
      'systemSettings' : 'System Settings',
      'signOut': 'Sign Out',
      'email': 'Email',
      'password': 'Password',
      'phoneNumber': 'Phone Number',
      'fullName': 'Full Name',
      'fullNameAsOnId': 'Full Name (as on ID Card)',
      'whatsappNumber': 'WhatsApp Number',
      'useSameForWhatsApp': 'Use the same number for WhatsApp',
      'contactInformation': 'Contact Information',
      'provideContactDetails': 'Provide your contact details for people to reach you.',
      'nextReviewReport': 'NEXT: Review Report',
      'completeYourProfile': 'Complete Your Profile',
      'completeYourKyc': 'Complete your KYC',
      'sendOtp': 'Send OTP',
      'verifyOtp': 'Verify OTP',
      'otpCode': 'OTP Code',
      'useTestNumber': 'Use Test Number (+237678439032)',
      'useTestCode': 'Use Test Code (123456)',
      'privacyPolicy': 'Privacy Policy',
      'agreeToPolicy': 'I have read and agree to the Privacy Policy',
      'settings': 'Settings',
      'accountSettings': 'Account Settings',
      'profileInformation': 'Profile Information',
      'kycSettings': 'KYC Settings',
      'kycVerificationStatus': 'KYC Verification Status',
      'verified': 'Verified',
      'notVerified': 'Not Verified',
      'language': 'Language',
      'english': 'English',
      'french': 'French',
      'theme': 'Theme',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'notifications': 'Notifications',
      'enableNotifications': 'Enable Notifications',
      'about': 'About',
      'version': 'Version',
      'deleteAccount': 'Delete Account',
      'deleteAccountConfirmation': 'Are you sure you want to delete your account? This action cannot be undone.',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'home': 'Home',
      'search': 'Search',
      'myReports': 'My Reports',
      'savedReports': 'Saved Reports',
      'createReport': 'Create a Report',
      'whatWouldYouLikeToReport': 'What would you like to report?',
      'register': 'Register',
      'pleaseSignIn': 'Please sign in to create a report and help us keep the community safe.',
      'lostItem': 'Lost Item',
      'foundItem': 'Found Item',
      'profileNotVerified': 'Your profile is not fully verified. Consider completing KYC for full trust.',
      'verifyNow': 'Verify Now',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'retry': 'Retry',
      'noData': 'No data available',
      'save': 'Save',
      'edit': 'Edit',
      'back': 'Back',
      'next': 'Next',
      'submit': 'Submit',
      'confirm': 'Confirm',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'close': 'Close',
      'done': 'Done',
      'skip': 'Skip',
      'continueText': 'Continue',
      'finish': 'Finish',
      'required': 'Required',
      'optional': 'Optional',
      'invalidInput': 'Invalid input',
      'pleaseEnterValidData': 'Please enter valid data',
      'networkError': 'Network error',
      'tryAgainLater': 'Please try again later',
      'connectionFailed': 'Connection failed',
      'checkYourConnection': 'Please check your internet connection',
      'searchLostFound': 'Search Lost & Found',
      'searchByOwner': 'Search by owner, document, location...',
      'filterSearch': 'Filter Search',
      'startTypingToSearch': 'Start typing to search for lost or found items, or use filters to narrow down results.',
      'fetchingReports': 'Fetching reports...',
      'noResultsFound': 'No results found matching your criteria.',
      'noReportsFound': 'No reports found. Try a different search or adjust your filters.',
      'recentSearches': 'Recent Searches',
      'errorLoadingReports': 'Error loading reports: {error}',
      'errorLoadingFilterOptions': 'Error loading filter options: {error}',
      'signInToManage' : 'Sign in to manage profile',
      'searchItems': 'Search items',
      'moreOptions': 'More options',
      'sendFeedback': 'Send Feedback',
      'feedbackComingSoon': 'Feedback feature coming soon!',
      'help': 'Help',
      'helpNotAvailable': 'Help content not yet available.',
      'all': 'All',
      'lost': 'Lost',
      'found': 'Found',
      'offlineDataMightBeOutdated': 'You are offline. Data might be outdated.',
      'makeAReport': 'Make a Report',
      'createNewReportTooltip': 'Create a new lost or found report',
      'loadingReports': 'Loading reports...',
      'noReportsFoundForFilter': 'No {filter} reports found.',
      'tryChangingFilter': 'Try changing your filter or create a new report.',
      'noReportsFoundYet': 'No reports found yet.',
      'beTheFirstToReport': 'Be the first to make a report!',
      'offlineContentOutdated': 'You are offline. Content may not be up-to-date.',
      'oopsSomethingWentWrong': 'Oops! Something went wrong.',
      'unknownErrorOccurred': 'An unknown error occurred.',
      'loadingMoreReports': 'Loading more reports...',
      'scrollDownToLoadMore': 'Scroll down to load more',
      'noMoreReports': 'No more reports',
      'myReportsTitle': 'My Reports',
      'reportUpdatedSuccess': 'Report updated successfully',
      'failedToDeleteReport': 'Failed to delete report: {error}',
      'reportDeletedSuccess': 'Report deleted successfully',
      'reportMarkedAs': 'Report marked as {status}',
      'failedToUpdateStatus': 'Failed to update status: {error}',
      'deleteReportTitle': 'Delete Report',
      'deleteReportConfirm': 'Are you sure you want to delete this report? This action cannot be undone.',
      'loadingAuthStatus': 'Loading authentication status...',
      'signInToViewReports': 'Sign in to view your reports',
      'trackAndManageReports': 'Track and manage all your submitted reports in one place',
      'createNewReport': 'Create New Report',
      'loadingYourReports': 'Loading your reports...',
      'noReportsYet': 'No reports yet',
      'createFirstReport': 'Create your first report to help find lost items or report found ones',
      'whatToReport': 'What would you like to report?',
      'pleaseSignInToReport': 'Please sign in to create a report and help us keep the community safe.',
      'profileNotVerifiedWarning': 'Your profile is not fully verified. Consider completing KYC for full trust.',
      'completeYourProfileTitle': 'Complete Your Profile (KYC)',
      'kycEnhancesTrust': 'Your profile is not fully verified. Completing KYC enhances trust and security for interactions on Back2u.',
      'completeOrProceed': 'Do you want to complete it now or proceed with your report without it?',
      'continueAnyway': 'Continue Anyway',
      'completeNow': 'Complete Now',
      'pleaseLogInToSave': 'Please log in to save reports.',
      'reportRemovedFromSaved': 'Report removed from saved.',
      'reportAddedToSaved': 'Report added to saved.',
      'mySavedReportsTitle': 'My Saved Reports',
      'logInToViewSaved': 'Please log in to view your saved reports.',
      'loadingSavedReports': 'Loading your saved reports...',
      'errorLoadingSavedReports': 'Error loading saved reports',
      'noSavedReportsYet': 'No saved reports yet',
      'browseAndSaveReports': 'Browse reports and tap the bookmark icon to save them here.',
      'browseReports': 'Browse Reports'
    },
    'fr': {
      'appTitle': 'Back2U',
      'signInToManage' : 'Connectez-vous pour gérer le profil',
      'welcome': 'Bienvenue',
      'getStarted': 'Commencer',
      'howItWorks': 'Comment ça marche',
      'connect': 'Se connecter',
      'signIn': 'Se connecter',
      'signInWithGoogle': 'Se connecter avec Google',
      'signInAnonymously': 'Continuer en tant qu\'invité',
      'signOut': 'Se déconnecter',
'signInToViewKyc' : 'Connectez-vous pour voir le statut KYC',
      'completeKyc' : 'Compléter le KYC',
      'systemSettings' : 'Paramètres système',

      'email': 'Email',
      'password': 'Mot de passe',
      'phoneNumber': 'Numéro de téléphone',
      'fullName': 'Nom complet',
      'fullNameAsOnId': 'Nom complet (comme sur la carte d\'identité)',
      'whatsappNumber': 'Numéro WhatsApp',
      'useSameForWhatsApp': 'Utiliser le même numéro pour WhatsApp',
      'contactInformation': 'Informations de contact',
      'provideContactDetails': 'Fournissez vos coordonnées pour que les gens puissent vous joindre.',
      'nextReviewReport': 'SUIVANT: Examiner le rapport',
      'completeYourProfile': 'Complétez votre profil',
      'completeYourKyc': 'Complétez votre KYC',
      'sendOtp': 'Envoyer OTP',
      'verifyOtp': 'Vérifier OTP',
      'otpCode': 'Code OTP',
      'useTestNumber': 'Utiliser le numéro de test (+237678439032)',
      'useTestCode': 'Utiliser le code de test (123456)',
      'privacyPolicy': 'Politique de confidentialité',
      'agreeToPolicy': 'J\'ai lu et j\'accepte la politique de confidentialité',
      'settings': 'Paramètres',
      'accountSettings': 'Paramètres du compte',
      'profileInformation': 'Informations du profil',
      'kycSettings': 'Paramètres KYC',
      'kycVerificationStatus': 'Statut de vérification KYC',
      'verified': 'Vérifié',
      'notVerified': 'Non vérifié',
      'language': 'Langue',
      'english': 'Anglais',
      'french': 'Français',
      'theme': 'Thème',
      'light': 'Clair',
      'dark': 'Sombre',
      'system': 'Système',
      'notifications': 'Notifications',
      'enableNotifications': 'Activer les notifications',
      'about': 'À propos',
      'version': 'Version',
      'deleteAccount': 'Supprimer le compte',
      'deleteAccountConfirmation': 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action ne peut pas être annulée.',
      'cancel': 'Annuler',
      'delete': 'Supprimer',
      'home': 'Accueil',
      'search': 'Rechercher',
      'myReports': 'Mes rapports',
      'savedReports': 'Rapports sauvegardés',
      'createReport': 'Créer un rapport',
      'whatWouldYouLikeToReport': 'Que souhaitez-vous signaler ?',
      'register': 'S\'inscrire',
      'pleaseSignIn': 'Veuillez vous connecter pour créer un rapport et nous aider à maintenir la communauté en sécurité.',
      'lostItem': 'Objet perdu',
      'foundItem': 'Objet trouvé',
      'profileNotVerified': 'Votre profil n\'est pas entièrement vérifié. Envisagez de compléter le KYC pour une confiance totale.',
      'verifyNow': 'Vérifier maintenant',
      'loading': 'Chargement...',
      'error': 'Erreur',
      'success': 'Succès',
      'retry': 'Réessayer',
      'noData': 'Aucune donnée disponible',
      'save': 'Sauvegarder',
      'edit': 'Modifier',
      'back': 'Retour',
      'next': 'Suivant',
      'submit': 'Soumettre',
      'confirm': 'Confirmer',
      'yes': 'Oui',
      'no': 'Non',
      'ok': 'OK',
      'close': 'Fermer',
      'done': 'Terminé',
      'skip': 'Passer',
      'continueText': 'Continuer',
      'finish': 'Terminer',
      'required': 'Requis',
      'optional': 'Optionnel',
      'invalidInput': 'Entrée invalide',
      'pleaseEnterValidData': 'Veuillez entrer des données valides',
      'networkError': 'Erreur réseau',
      'tryAgainLater': 'Veuillez réessayer plus tard',
      'connectionFailed': 'Échec de connexion',
      'checkYourConnection': 'Veuillez vérifier votre connexion internet',
      'searchLostFound': 'Rechercher Objets Perdus & Trouvés',
      'searchByOwner': 'Rechercher par propriétaire, document, lieu...',
      'filterSearch': 'Filtrer la recherche',
      'startTypingToSearch': 'Commencez à taper pour rechercher des objets perdus ou trouvés, ou utilisez les filtres pour affiner les résultats.',
      'fetchingReports': 'Récupération des rapports...',
      'noResultsFound': 'Aucun résultat trouvé correspondant à vos critères.',
      'noReportsFound': 'Aucun rapport trouvé. Essayez une recherche différente ou ajustez vos filtres.',
      'recentSearches': 'Recherches récentes',
      'errorLoadingReports': 'Erreur lors du chargement des rapports: {error}',
      'errorLoadingFilterOptions': 'Erreur lors du chargement des options de filtre: {error}',
      'searchItems': 'Rechercher des articles',
      'moreOptions': 'Plus d\'options',
      'sendFeedback': 'Envoyer des commentaires',
      'feedbackComingSoon': 'Fonctionnalité de commentaires bientôt disponible !',
      'help': 'Aide',
      'helpNotAvailable': 'Contenu d\'aide non encore disponible.',
      'all': 'Tout',
      'lost': 'Perdu',
      'found': 'Trouvé',
      'offlineDataMightBeOutdated': 'Vous êtes hors ligne. Les données peuvent ne pas être à jour.',
      'makeAReport': 'Faire un rapport',
      'createNewReportTooltip': 'Créer un nouveau rapport d\'objet perdu ou trouvé',
      'loadingReports': 'Chargement des rapports...',
      'noReportsFoundForFilter': 'Aucun rapport {filter} trouvé.',
      'tryChangingFilter': 'Essayez de changer de filtre ou de créer un nouveau rapport.',
      'noReportsFoundYet': 'Aucun rapport trouvé pour l\'instant.',
      'beTheFirstToReport': 'Soyez le premier à faire un rapport !',
      'offlineContentOutdated': 'Vous êtes hors ligne. Le contenu peut ne pas être à jour.',
      'oopsSomethingWentWrong': 'Oups ! Quelque chose s\'est mal passé.',
      'unknownErrorOccurred': 'Une erreur inconnue est survenue.',
      'loadingMoreReports': 'Chargement de plus de rapports...',
      'scrollDownToLoadMore': 'Faites défiler pour en charger plus',
      'noMoreReports': 'Plus de rapports',
      'myReportsTitle': 'Mes rapports',
      'reportUpdatedSuccess': 'Rapport mis à jour avec succès',
      'failedToDeleteReport': 'Échec de la suppression du rapport: {error}',
      'reportDeletedSuccess': 'Rapport supprimé avec succès',
      'reportMarkedAs': 'Rapport marqué comme {status}',
      'failedToUpdateStatus': 'Échec de la mise à jour du statut: {error}',
      'deleteReportTitle': 'Supprimer le rapport',
      'deleteReportConfirm': 'Êtes-vous sûr de vouloir supprimer ce rapport ? Cette action est irréversible.',
      'loadingAuthStatus': 'Chargement du statut d\'authentification...',
      'signInToViewReports': 'Connectez-vous pour voir vos rapports',
      'trackAndManageReports': 'Suivez et gérez tous vos rapports soumis en un seul endroit',
      'createNewReport': 'Créer un nouveau rapport',
      'loadingYourReports': 'Chargement de vos rapports...',
      'noReportsYet': 'Aucun rapport pour l\'instant',
      'createFirstReport': 'Créez votre premier rapport pour aider à retrouver des objets perdus ou signaler ceux trouvés',
      'whatToReport': 'Que souhaitez-vous signaler ?',
      'pleaseSignInToReport': 'Veuillez vous connecter pour créer un rapport et nous aider à garder la communauté en sécurité.',
      'profileNotVerifiedWarning': 'Votre profil n\'est pas entièrement vérifié. Pensez à compléter le KYC pour une confiance totale.',
      'completeYourProfileTitle': 'Complétez votre profil (KYC)',
      'kycEnhancesTrust': 'Votre profil n\'est pas entièrement vérifié. Compléter le KYC améliore la confiance et la sécurité pour les interactions sur Back2u.',
      'completeOrProceed': 'Voulez-vous le compléter maintenant ou continuer avec votre rapport sans cela ?',
      'continueAnyway': 'Continuer quand même',
      'completeNow': 'Compléter maintenant',
      'pleaseLogInToSave': 'Veuillez vous connecter pour enregistrer les rapports.',
      'reportRemovedFromSaved': 'Rapport supprimé des favoris.',
      'reportAddedToSaved': 'Rapport ajouté aux favoris.',
      'mySavedReportsTitle': 'Mes rapports enregistrés',
      'logInToViewSaved': 'Veuillez vous connecter pour voir vos rapports enregistrés.',
      'loadingSavedReports': 'Chargement de vos rapports enregistrés...',
      'errorLoadingSavedReports': 'Erreur lors du chargement des rapports enregistrés',
      'noSavedReportsYet': 'Aucun rapport enregistré pour le moment',
      'browseAndSaveReports': 'Parcourez les rapports et appuyez sur l\'icône de signet pour les enregistrer ici.',
      'browseReports': 'Parcourir les rapports'
    },
  };

  String get appTitle => _localizedValues[locale.languageCode]?['appTitle'] ?? 'Back2U';
  String get welcome => _localizedValues[locale.languageCode]?['welcome'] ?? 'Welcome';
  String get getStarted => _localizedValues[locale.languageCode]?['getStarted'] ?? 'Get Started';
  String get howItWorks => _localizedValues[locale.languageCode]?['howItWorks'] ?? 'How It Works';
  String get signInToViewKyc => _localizedValues[locale.languageCode]?['signInToViewKyc'] ?? 'Sign In to view Kyc status';
String get completeKyc => _localizedValues[locale.languageCode]?['completeKyc'] ?? 'Complete KYC';
String get systemSettings => _localizedValues[locale.languageCode]?['systemSettings'] ?? 'System settings';
String get signInToManage => _localizedValues[locale.languageCode]?['signInToManage'] ?? 'Sign in to manage profile';
  String get connect => _localizedValues[locale.languageCode]?['connect'] ?? 'Connect';
  String get signIn => _localizedValues[locale.languageCode]?['signIn'] ?? 'Sign In';
  String get signInWithGoogle => _localizedValues[locale.languageCode]?['signInWithGoogle'] ?? 'Sign in with Google';
  String get signInAnonymously => _localizedValues[locale.languageCode]?['signInAnonymously'] ?? 'Continue as Guest';
  String get signOut => _localizedValues[locale.languageCode]?['signOut'] ?? 'Sign Out';
  String get email => _localizedValues[locale.languageCode]?['email'] ?? 'Email';
  String get password => _localizedValues[locale.languageCode]?['password'] ?? 'Password';
  String get phoneNumber => _localizedValues[locale.languageCode]?['phoneNumber'] ?? 'Phone Number';
  String get fullName => _localizedValues[locale.languageCode]?['fullName'] ?? 'Full Name';
  String get fullNameAsOnId => _localizedValues[locale.languageCode]?['fullNameAsOnId'] ?? 'Full Name (as on ID Card)';
  String get whatsappNumber => _localizedValues[locale.languageCode]?['whatsappNumber'] ?? 'WhatsApp Number';
  String get useSameForWhatsApp => _localizedValues[locale.languageCode]?['useSameForWhatsApp'] ?? 'Use the same number for WhatsApp';
  String get contactInformation => _localizedValues[locale.languageCode]?['contactInformation'] ?? 'Contact Information';
  String get provideContactDetails => _localizedValues[locale.languageCode]?['provideContactDetails'] ?? 'Provide your contact details for people to reach you.';
  String get nextReviewReport => _localizedValues[locale.languageCode]?['nextReviewReport'] ?? 'NEXT: Review Report';
  String get completeYourProfile => _localizedValues[locale.languageCode]?['completeYourProfile'] ?? 'Complete Your Profile';
  String get completeYourKyc => _localizedValues[locale.languageCode]?['completeYourKyc'] ?? 'Complete your KYC';
  String get sendOtp => _localizedValues[locale.languageCode]?['sendOtp'] ?? 'Send OTP';
  String get verifyOtp => _localizedValues[locale.languageCode]?['verifyOtp'] ?? 'Verify OTP';
  String get otpCode => _localizedValues[locale.languageCode]?['otpCode'] ?? 'OTP Code';
  String get useTestNumber => _localizedValues[locale.languageCode]?['useTestNumber'] ?? 'Use Test Number (+237678439032)';
  String get useTestCode => _localizedValues[locale.languageCode]?['useTestCode'] ?? 'Use Test Code (123456)';
  String get privacyPolicy => _localizedValues[locale.languageCode]?['privacyPolicy'] ?? 'Privacy Policy';
  String get agreeToPolicy => _localizedValues[locale.languageCode]?['agreeToPolicy'] ?? 'I have read and agree to the Privacy Policy';
  String get settings => _localizedValues[locale.languageCode]?['settings'] ?? 'Settings';
  String get accountSettings => _localizedValues[locale.languageCode]?['accountSettings'] ?? 'Account Settings';
  String get profileInformation => _localizedValues[locale.languageCode]?['profileInformation'] ?? 'Profile Information';
  String get kycSettings => _localizedValues[locale.languageCode]?['kycSettings'] ?? 'KYC Settings';
  String get kycVerificationStatus => _localizedValues[locale.languageCode]?['kycVerificationStatus'] ?? 'KYC Verification Status';
  String get verified => _localizedValues[locale.languageCode]?['verified'] ?? 'Verified';
  String get notVerified => _localizedValues[locale.languageCode]?['notVerified'] ?? 'Not Verified';
  String get language => _localizedValues[locale.languageCode]?['language'] ?? 'Language';
  String get english => _localizedValues[locale.languageCode]?['english'] ?? 'English';
  String get french => _localizedValues[locale.languageCode]?['french'] ?? 'French';
  String get theme => _localizedValues[locale.languageCode]?['theme'] ?? 'Theme';
  String get light => _localizedValues[locale.languageCode]?['light'] ?? 'Light';
  String get dark => _localizedValues[locale.languageCode]?['dark'] ?? 'Dark';
  String get system => _localizedValues[locale.languageCode]?['system'] ?? 'System';
  String get notifications => _localizedValues[locale.languageCode]?['notifications'] ?? 'Notifications';
  String get enableNotifications => _localizedValues[locale.languageCode]?['enableNotifications'] ?? 'Enable Notifications';
  String get about => _localizedValues[locale.languageCode]?['about'] ?? 'About';
  String get version => _localizedValues[locale.languageCode]?['version'] ?? 'Version';
  String get deleteAccount => _localizedValues[locale.languageCode]?['deleteAccount'] ?? 'Delete Account';
  String get deleteAccountConfirmation => _localizedValues[locale.languageCode]?['deleteAccountConfirmation'] ?? 'Are you sure you want to delete your account? This action cannot be undone.';
  String get cancel => _localizedValues[locale.languageCode]?['cancel'] ?? 'Cancel';
  String get delete => _localizedValues[locale.languageCode]?['delete'] ?? 'Delete';
  String get home => _localizedValues[locale.languageCode]?['home'] ?? 'Home';
  String get search => _localizedValues[locale.languageCode]?['search'] ?? 'Search';
  String get myReports => _localizedValues[locale.languageCode]?['myReports'] ?? 'My Reports';
  String get savedReports => _localizedValues[locale.languageCode]?['savedReports'] ?? 'Saved Reports';
  String get createReport => _localizedValues[locale.languageCode]?['createReport'] ?? 'Create a Report';
  String get whatWouldYouLikeToReport => _localizedValues[locale.languageCode]?['whatWouldYouLikeToReport'] ?? 'What would you like to report?';
  String get register => _localizedValues[locale.languageCode]?['register'] ?? 'Register';
  String get pleaseSignIn => _localizedValues[locale.languageCode]?['pleaseSignIn'] ?? 'Please sign in to create a report and help us keep the community safe.';
  String get lostItem => _localizedValues[locale.languageCode]?['lostItem'] ?? 'Lost Item';
  String get foundItem => _localizedValues[locale.languageCode]?['foundItem'] ?? 'Found Item';
  String get profileNotVerified => _localizedValues[locale.languageCode]?['profileNotVerified'] ?? 'Your profile is not fully verified. Consider completing KYC for full trust.';
  String get verifyNow => _localizedValues[locale.languageCode]?['verifyNow'] ?? 'Verify Now';
  String get loading => _localizedValues[locale.languageCode]?['loading'] ?? 'Loading...';
  String get error => _localizedValues[locale.languageCode]?['error'] ?? 'Error';
  String get success => _localizedValues[locale.languageCode]?['success'] ?? 'Success';
  String get retry => _localizedValues[locale.languageCode]?['retry'] ?? 'Retry';
  String get noData => _localizedValues[locale.languageCode]?['noData'] ?? 'No data available';
  String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get edit => _localizedValues[locale.languageCode]?['edit'] ?? 'Edit';
  String get back => _localizedValues[locale.languageCode]?['back'] ?? 'Back';
  String get next => _localizedValues[locale.languageCode]?['next'] ?? 'Next';
  String get submit => _localizedValues[locale.languageCode]?['submit'] ?? 'Submit';
  String get confirm => _localizedValues[locale.languageCode]?['confirm'] ?? 'Confirm';
  String get yes => _localizedValues[locale.languageCode]?['yes'] ?? 'Yes';
  String get no => _localizedValues[locale.languageCode]?['no'] ?? 'No';
  String get ok => _localizedValues[locale.languageCode]?['ok'] ?? 'OK';
  String get close => _localizedValues[locale.languageCode]?['close'] ?? 'Close';
  String get done => _localizedValues[locale.languageCode]?['done'] ?? 'Done';
  String get skip => _localizedValues[locale.languageCode]?['skip'] ?? 'Skip';
  String get continueText => _localizedValues[locale.languageCode]?['continueText'] ?? 'Continue';
  String get finish => _localizedValues[locale.languageCode]?['finish'] ?? 'Finish';
  String get required_ => _localizedValues[locale.languageCode]?['required'] ?? 'Required';
  String get optional => _localizedValues[locale.languageCode]?['optional'] ?? 'Optional';
  String get invalidInput => _localizedValues[locale.languageCode]?['invalidInput'] ?? 'Invalid input';
  String get pleaseEnterValidData => _localizedValues[locale.languageCode]?['pleaseEnterValidData'] ?? 'Please enter valid data';
  String get networkError => _localizedValues[locale.languageCode]?['networkError'] ?? 'Network error';
  String get tryAgainLater => _localizedValues[locale.languageCode]?['tryAgainLater'] ?? 'Please try again later';
  String get connectionFailed => _localizedValues[locale.languageCode]?['connectionFailed'] ?? 'Connection failed';
  String get checkYourConnection => _localizedValues[locale.languageCode]?['checkYourConnection'] ?? 'Please check your internet connection';
  String get searchLostFound => _localizedValues[locale.languageCode]?['searchLostFound'] ?? 'Search Lost & Found';
  String get searchByOwner => _localizedValues[locale.languageCode]?['searchByOwner'] ?? 'Search by owner, document, location...';
  String get filterSearch => _localizedValues[locale.languageCode]?['filterSearch'] ?? 'Filter Search';
  String get startTypingToSearch => _localizedValues[locale.languageCode]?['startTypingToSearch'] ?? 'Start typing to search for lost or found items, or use filters to narrow down results.';
  String get fetchingReports => _localizedValues[locale.languageCode]?['fetchingReports'] ?? 'Fetching reports...';
  String get noResultsFound => _localizedValues[locale.languageCode]?['noResultsFound'] ?? 'No results found matching your criteria.';
  String get noReportsFound => _localizedValues[locale.languageCode]?['noReportsFound'] ?? 'No reports found. Try a different search or adjust your filters.';
  String get recentSearches => _localizedValues[locale.languageCode]?['recentSearches'] ?? 'Recent Searches';
  
  String errorLoadingReports(String error) => _localizedValues[locale.languageCode]?['errorLoadingReports']?.replaceAll('{error}', error) ?? 'Error loading reports: $error';
  String errorLoadingFilterOptions(String error) => _localizedValues[locale.languageCode]?['errorLoadingFilterOptions']?.replaceAll('{error}', error) ?? 'Error loading filter options: $error';
  
  String noReportsFoundForFilter(String filter) => _localizedValues[locale.languageCode]?['noReportsFoundForFilter']?.replaceAll('{filter}', filter) ?? 'No {filter} reports found.'.replaceAll('{filter}', filter);
  String reportMarkedAs(String status) => _localizedValues[locale.languageCode]?['reportMarkedAs']?.replaceAll('{status}', status) ?? 'Report marked as {status}'.replaceAll('{status}', status);
  String failedToDeleteReport(String error) => _localizedValues[locale.languageCode]?['failedToDeleteReport']?.replaceAll('{error}', error) ?? 'Failed to delete report: {error}'.replaceAll('{error}', error);
  String failedToUpdateStatus(String error) => _localizedValues[locale.languageCode]?['failedToUpdateStatus']?.replaceAll('{error}', error) ?? 'Failed to update status: {error}'.replaceAll('{error}', error);

  String reportsCount(int count) {
    if (locale.languageCode == 'fr') {
      return count <= 1 ? '$count rapport' : '$count rapports';
    }
    return count == 1 ? '$count report' : '$count reports';
  }

  String savedReportsCount(int count) {
    if (locale.languageCode == 'fr') {
      return count <= 1 ? '$count rapport enregistré' : '$count rapports enregistrés';
    }
    return count == 1 ? '$count saved report' : '$count saved reports';
  }

  String get searchItems => _localizedValues[locale.languageCode]?['searchItems'] ?? 'Search items';
  String get moreOptions => _localizedValues[locale.languageCode]?['moreOptions'] ?? 'More options';
  String get sendFeedback => _localizedValues[locale.languageCode]?['sendFeedback'] ?? 'Send Feedback';
  String get feedbackComingSoon => _localizedValues[locale.languageCode]?['feedbackComingSoon'] ?? 'Feedback feature coming soon!';
  String get help => _localizedValues[locale.languageCode]?['help'] ?? 'Help';
  String get helpNotAvailable => _localizedValues[locale.languageCode]?['helpNotAvailable'] ?? 'Help content not yet available.';
  String get all => _localizedValues[locale.languageCode]?['all'] ?? 'All';
  String get lost => _localizedValues[locale.languageCode]?['lost'] ?? 'Lost';
  String get found => _localizedValues[locale.languageCode]?['found'] ?? 'Found';
  String get offlineDataMightBeOutdated => _localizedValues[locale.languageCode]?['offlineDataMightBeOutdated'] ?? 'You are offline. Data might be outdated.';
  String get makeAReport => _localizedValues[locale.languageCode]?['makeAReport'] ?? 'Make a Report';
  String get createNewReportTooltip => _localizedValues[locale.languageCode]?['createNewReportTooltip'] ?? 'Create a new lost or found report';
  String get loadingReports => _localizedValues[locale.languageCode]?['loadingReports'] ?? 'Loading reports...';
  String get tryChangingFilter => _localizedValues[locale.languageCode]?['tryChangingFilter'] ?? 'Try changing your filter or create a new report.';
  String get noReportsFoundYet => _localizedValues[locale.languageCode]?['noReportsFoundYet'] ?? 'No reports found yet.';
  String get beTheFirstToReport => _localizedValues[locale.languageCode]?['beTheFirstToReport'] ?? 'Be the first to make a report!';
  String get offlineContentOutdated => _localizedValues[locale.languageCode]?['offlineContentOutdated'] ?? 'You are offline. Content may not be up-to-date.';
  String get oopsSomethingWentWrong => _localizedValues[locale.languageCode]?['oopsSomethingWentWrong'] ?? 'Oops! Something went wrong.';
  String get unknownErrorOccurred => _localizedValues[locale.languageCode]?['unknownErrorOccurred'] ?? 'An unknown error occurred.';
  String get loadingMoreReports => _localizedValues[locale.languageCode]?['loadingMoreReports'] ?? 'Loading more reports...';
  String get scrollDownToLoadMore => _localizedValues[locale.languageCode]?['scrollDownToLoadMore'] ?? 'Scroll down to load more';
  String get noMoreReports => _localizedValues[locale.languageCode]?['noMoreReports'] ?? 'No more reports';
  String get myReportsTitle => _localizedValues[locale.languageCode]?['myReportsTitle'] ?? 'My Reports';
  String get reportUpdatedSuccess => _localizedValues[locale.languageCode]?['reportUpdatedSuccess'] ?? 'Report updated successfully';
  String get reportDeletedSuccess => _localizedValues[locale.languageCode]?['reportDeletedSuccess'] ?? 'Report deleted successfully';
  String get deleteReportTitle => _localizedValues[locale.languageCode]?['deleteReportTitle'] ?? 'Delete Report';
  String get deleteReportConfirm => _localizedValues[locale.languageCode]?['deleteReportConfirm'] ?? 'Are you sure you want to delete this report? This action cannot be undone.';
  String get loadingAuthStatus => _localizedValues[locale.languageCode]?['loadingAuthStatus'] ?? 'Loading authentication status...';
  String get signInToViewReports => _localizedValues[locale.languageCode]?['signInToViewReports'] ?? 'Sign in to view your reports';
  String get trackAndManageReports => _localizedValues[locale.languageCode]?['trackAndManageReports'] ?? 'Track and manage all your submitted reports in one place';
  String get createNewReport => _localizedValues[locale.languageCode]?['createNewReport'] ?? 'Create New Report';
  String get loadingYourReports => _localizedValues[locale.languageCode]?['loadingYourReports'] ?? 'Loading your reports...';
  String get noReportsYet => _localizedValues[locale.languageCode]?['noReportsYet'] ?? 'No reports yet';
  String get createFirstReport => _localizedValues[locale.languageCode]?['createFirstReport'] ?? 'Create your first report to help find lost items or report found ones';
  String get whatToReport => _localizedValues[locale.languageCode]?['whatToReport'] ?? 'What would you like to report?';
  String get pleaseSignInToReport => _localizedValues[locale.languageCode]?['pleaseSignInToReport'] ?? 'Please sign in to create a report and help us keep the community safe.';
  String get profileNotVerifiedWarning => _localizedValues[locale.languageCode]?['profileNotVerifiedWarning'] ?? 'Your profile is not fully verified. Consider completing KYC for full trust.';
  String get completeYourProfileTitle => _localizedValues[locale.languageCode]?['completeYourProfileTitle'] ?? 'Complete Your Profile (KYC)';
  String get kycEnhancesTrust => _localizedValues[locale.languageCode]?['kycEnhancesTrust'] ?? 'Your profile is not fully verified. Completing KYC enhances trust and security for interactions on Back2u.';
  String get completeOrProceed => _localizedValues[locale.languageCode]?['completeOrProceed'] ?? 'Do you want to complete it now or proceed with your report without it?';
  String get continueAnyway => _localizedValues[locale.languageCode]?['continueAnyway'] ?? 'Continue Anyway';
  String get completeNow => _localizedValues[locale.languageCode]?['completeNow'] ?? 'Complete Now';
  String get pleaseLogInToSave => _localizedValues[locale.languageCode]?['pleaseLogInToSave'] ?? 'Please log in to save reports.';
  String get reportRemovedFromSaved => _localizedValues[locale.languageCode]?['reportRemovedFromSaved'] ?? 'Report removed from saved.';
  String get reportAddedToSaved => _localizedValues[locale.languageCode]?['reportAddedToSaved'] ?? 'Report added to saved.';
  String get mySavedReportsTitle => _localizedValues[locale.languageCode]?['mySavedReportsTitle'] ?? 'My Saved Reports';
  String get logInToViewSaved => _localizedValues[locale.languageCode]?['logInToViewSaved'] ?? 'Please log in to view your saved reports.';
  String get loadingSavedReports => _localizedValues[locale.languageCode]?['loadingSavedReports'] ?? 'Loading your saved reports...';
  String get errorLoadingSavedReports => _localizedValues[locale.languageCode]?['errorLoadingSavedReports'] ?? 'Error loading saved reports';
  String get noSavedReportsYet => _localizedValues[locale.languageCode]?['noSavedReportsYet'] ?? 'No saved reports yet';
  String get browseAndSaveReports => _localizedValues[locale.languageCode]?['browseAndSaveReports'] ?? 'Browse reports and tap the bookmark icon to save them here.';
  String get browseReports => _localizedValues[locale.languageCode]?['browseReports'] ?? 'Browse Reports';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
} 