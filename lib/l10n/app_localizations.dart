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
      'rewardOffered': 'Reward Offered',
      'amount': 'Amount',
      'reward': 'Reward',
      'notAvailable': 'Not Available',
      'update': 'Update',
      'updatingReport': 'Updating Report',
      'reportUpdated': 'Report Updated',
      'confirmAndUpdate': 'Confirm and Update',
      'confirmAndSubmit': 'Confirm and Submit',
      'submittingReport': 'Submitting Report',
      'reportSubmitted': 'Report Submitted',
      'updateReport': 'Update Report',
      'submitReport': 'Submit Report',
      'updatingYourReport': 'Updating Your Report',
      'submittingYourReport': 'Submitting Your Report',
      'pleaseDoNotCloseApp': 'Please do not close the app until the report is submitted.',
      'submissionInProgress': 'Submission in Progress',
      'submissionInProgressMessage': 'Please wait while we process your submission.',
      'submissionFailed': 'Submission Failed',
      'submissionFailedMessage': 'Please try again later.',
      'submissionSuccess': 'Submission Successful',
      'submissionSuccessMessage': 'Your report has been submitted successfully.',
      'reportSubmittedSuccess': 'Report submitted successfully',
      'reportUpdatedSuccess': 'Report updated successfully',
      'reportDeletedSuccess': 'Report deleted successfully',
      'reportMarkedAs': 'Report marked as {status}',
      'failedToUpdateStatus': 'Failed to update status: {error}',
      'deleteReportTitle': 'Delete Report',
      'deleteReportConfirm': 'Are you sure you want to delete this report? This action cannot be undone.',
      'updateTimedOut': 'Update timed out',
      'submissionTimedOut': 'Submission timed out',
      'submissionTimedOutMessage': 'Please try again later.',
      'noInternetConnection': 'No internet connection',
      'serverUnreachable': 'Server unreachable',
      'permissionDenied': 'Permission denied',
      'unauthenticated': 'Unauthenticated',
      'firebaseError': 'Firebase error: {error}',
      'failedToUpdateReportGeneric': 'Failed to update report',
      'failedToSubmitReportGeneric': 'Failed to submit report',
      'noActiveNetwork': 'No active network',
      'authenticationExpired': 'Authentication expired',
      'authenticationExpiredMessage': 'Please sign in again to continue.',
      'authenticationExpiredTitle': 'Authentication Expired',
      'authenticationExpiredDescription': 'Please sign in again to continue.',
      'authenticationExpiredButton': 'Sign In',
      'authenticationExpiredButtonText': 'Sign In',
      'serverUnreachableMessage': 'Please try again later.',
      'serverUnreachableTitle': 'Server Unreachable',
      'serverUnreachableDescription': 'Please try again later.',
      'serverUnreachableButton': 'Try Again',
      'serverUnreachableButtonText': 'Try Again',
      'reviewReportCarefully': 'Review report carefully',
      
      // Notifications page translations
      'deleteClaimTitle': 'Delete Claim',
      'deleteClaimConfirm': 'Are you sure you want to delete this claim? This action cannot be undone.',
      'signInRequired': 'Sign In Required',
      'signInToViewNotifications': 'Please sign in to view your notifications.',
      'errorLoading': 'Error Loading',
      'tryAgain': 'Try Again',
      'noNotifications': 'No Notifications',
      'noNotificationsSubtitle': 'You don\'t have any notifications yet. They will appear here when you receive claims or status updates.',
      
      // SimpleCard and ReportDetails translations
      'resolved': 'RESOLVED',
      'reported': 'Reported',
      'ago': 'ago',
      'editReport': 'Edit Report',
      'markAsActive': 'Mark as Active',
      'markAsResolved': 'Mark as Resolved',
      'deleteReport': 'Delete Report',
      'unsaveReport': 'Unsave Report',
      'saveReport': 'Save Report',
      'options': 'Options',
      'basicInformation': 'Basic Information',
      'documentOwner': 'Document Owner',
      'locationAndDates': 'Location & Dates',
      'reportedOn': 'Reported On',
      'additionalNotes': 'Additional Notes',
      'images': 'Images',
      'allImages': 'All Images',
      'main': 'Main',
      'imageNotAvailable': 'Image not available',
      'youCreatedThisReport': 'You created this report',
      'saved': 'Saved',
      'claimThisReport': 'Claim this report',
      'alreadyClaimed': 'Already Claimed',
      'alreadyClaimedMessage': 'You have already submitted a claim for this report.',
      'shareReport': 'Share Report',
      'pleaseSignInToSave': 'Please sign in to save reports',
      'cannotSaveOwnReport': 'You can\'t save your own report. View your reports in the \'My Reports\' section.',
      'reportSaved': 'Report saved!',
      'reportRemoved': 'Report removed',
      'failedToSave': 'Failed to save: {error}',
      'pleaseVerifyPhoneToShare': 'Please verify your phone number to share this report',
      'failedToShare': 'Failed to share: {error}',
      'couldNotLaunch': 'Could not launch {url}',
      'cannotClaimOwnReport': 'You cannot claim your own report.',
      'pleaseSignInToContinue': 'Please sign in to continue.',
      'pleaseCompleteProfile': 'Please complete your profile to continue.',
      'claimSent': 'Claim sent! The owner will review your message and images.',
      'claimItem': 'Claim {type} Item',
      'provideProofFound': 'Provide proof that you found this item',
      'provideProofBelongs': 'Provide proof that this item belongs to you',
      'message': 'Message',
      'describeHowFound': 'Describe how you found the item...',
      'describeItemAndProof': 'Describe the item and provide proof...',
      'tooLong': 'Too long',
      'minChars': 'Min {count} chars',
      'imagesRequired': 'Images *Required',
      'imagesOptional': 'Images (Optional)',
      'gallery': 'Gallery',
      'camera': 'Camera',
      'submitClaim': 'Submit Claim',
      'submitting': 'Submitting...',
      'confirmClaim': 'Confirm Claim',
      'submitClaimForItem': 'Submit claim for {type} item?',
      'maximumImagesAllowed': 'Maximum {count} images allowed',
      'failedToPickImages': 'Failed to pick images: {error}',
      'failedToTakePhoto': 'Failed to take photo: {error}',
      'pleaseEnterMinChars': 'Please enter at least {count} characters',
      'pleaseSelectImageForLost': 'Please select at least one image for lost item claims',
      'failedToSubmitClaim': 'Failed to submit claim: {error}',
      
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
      'searchByOwner': 'Search by owner',
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
      'notSet':"Not Set",
      'signInToManageProfile':"Sign in to manage profile",
      'phoneManagement':"Phone Management",
      'noPhoneNumberSet':"No phone number set",
      'phoneNumberSet':"Phone number set",
      'phoneNumberNotSet':"Phone number not set",
      'yourProfileIsAlreadyVerified':"Your profile is already verified",
      'yourProfileIsNotVerified':"Your profile is not verified",
      'yourProfileIsNotFullyVerified':"Your profile is not fully verified",
      'yourProfileIsFullyVerified':"Your profile is fully verified",
      'yourProfileIsNotVerifiedWarning':"Your profile is not fully verified. Consider completing KYC for full trust.",
      'yourProfileIsNotVerifiedWarningDescription':"Your profile is not fully verified. Consider completing KYC for full trust.",
      'yourProfileIsNotVerifiedWarningButton':"CompletenotificationsEnabled    KYC",
'notificationsDisabled':"Notifications disabled",
'themeSetTo':'Theme set to',
'notificationsEnabled':"Notifications enabled",
'notificationsDisabledDescription':"Notifications are disabled. You can enable them in the settings.",
'notificationsEnabledDescription':"Notifications are enabled. You can disable them in the settings.",
'notificationsDisabledButton':"Disable Notifications",
'notificationsEnabledButton':"Enable Notifications",
'notificationsDisabledButtonText':"Disable Notifications",
      'offlineDataMightBeOutdated': 'You are offline. Data might  be outdated.',
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
      
      'failedToDeleteReport': 'Failed to delete report: {error}',
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
      'confirmUnsave': 'Confirm Unsave',
      'confirmUnsaveDescription': 'Are you sure you want to remove this report from your saved items?',
      'unsave': 'Unsave',
      'mySavedReportsTitle': 'My Saved Reports',
      'logInToViewSaved': 'Please log in to view your saved reports.',
      'loadingSavedReports': 'Loading your saved reports...',
      'errorLoadingSavedReports': 'Error loading saved reports',
      'noSavedReportsYet': 'No saved reports yet',
      'browseAndSaveReports': 'Browse reports and tap the bookmark icon to save them here.',
      'browseReports': 'Browse Reports',
      'termsOfService': 'Terms of Service',
      'aboutApp': 'About App',
      'helpAndSupport': 'Help & Support',
      'feedback': 'Feedback',
      'deleteAccountConfirmationTitle': 'Delete Account',
      'deleteAccountConfirmationContent': 'Are you sure you want to delete your account? This action cannot be undone.',
      'suggestion': 'Suggestion',
      'other': 'Other',
      'inAppMessage': 'In-app Message',
      'doNotContactMe': 'Do not contact me',
      'verifiedPhoneFromProfile': 'This is the verified phone number from your profile.',
      'pleaseSelectIncidentDate': 'Please select the incident date.',
      'pleaseFillRequiredFields': 'Please fill in all required fields and fix errors.',
      'similarReportFound': 'Similar Report Found',
      'similarReportDescription': 'A report with very similar details already exists in our system. Please review it to avoid creating a duplicate.',
      'otherSimilarReportsFound': '+{count} other similar reports found.',
      'viewExistingReport': 'View Existing Report',
      'report': 'Report',
      'details': 'Details',
      'ownerNameRequired': 'Owner\'s Name (or Name on Item)*',
      'pleaseEnterOwnerName': 'Please enter the owner\'s name or name on the item',
      'pleaseSelectCategory': 'Please select a category',
      'subcategory': 'Subcategory',
      'pleaseSelectSubcategory': 'Please select a subcategory',
      'selectCategoryFirst': 'Select a category first',
      'incidentDate': 'Incident Date',
      'selectDate': 'Select Date',
      'mainLocation': 'Main Location',
      'pleaseSelectMainLocation': 'Please select a main location',
      'subLocation': 'Sub-Location',
      'pleaseSelectSubLocation': 'Please select a sub-location',
      'selectMainLocationFirst': 'Select a main location first',
      'additionalNotesOptional': 'Additional Notes (Optional)',
      'enterExtraInformation': 'Enter any extra information here...',
      'offerReward': 'Offer Reward?',
      'rewardAmountXAF': 'Reward Amount (XAF)',
      'pleaseEnterRewardAmount': 'Please enter the reward amount',
      'pleaseEnterValidNumber': 'Please enter a valid number',
      'amountMustBeGreaterThanZero': 'Amount must be greater than zero',
      'nextContactInformation': 'NEXT: Contact Information',
      'resetFormToOriginal': 'Reset Form to Original',
      'summary': 'Summary',
      'reviewReportDetails': 'Please review your report details carefully before submitting.',
      'itemDetails': 'Item Details',
      'type': 'Type',
      'ownerName': 'Owner Name',
      'submissionInProgressDescription': 'Your report is currently being processed. Please wait for the submission to complete.',
      
      // Notifications page translations
      // 'deleteClaimTitle': 'Supprimer la réclamation',
      // 'deleteClaimConfirm': 'Êtes-vous sûr de vouloir supprimer cette réclamation ? Cette action est irréversible.',
      // 'signInRequired': 'Connexion requise',
      // 'signInToViewNotifications': 'Veuillez vous connecter pour voir vos notifications.',
      // 'errorLoading': 'Erreur de chargement',
      // 'tryAgain': 'Réessayer',
      // 'noNotifications': 'Aucune notification',
      // 'noNotificationsSubtitle': 'Vous n\'avez pas encore de notifications. Elles apparaîtront ici lorsque vous recevrez des réclamations ou des mises à jour de statut.',
      
     
     
     
      
    
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
      'otherSimilarReportsFound': '+{count} autres rapports similaires trouvés.',
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
      'searchByOwner': 'Rechercher par propriétaire',
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
      'confirmUnsave': 'Confirmer la suppression',
      'confirmUnsaveDescription': 'Êtes-vous sûr de vouloir supprimer ce rapport de vos éléments sauvegardés ?',
      'unsave': 'Supprimer',
      'mySavedReportsTitle': 'Mes rapports enregistrés',
      'logInToViewSaved': 'Veuillez vous connecter pour voir vos rapports enregistrés.',
      'loadingSavedReports': 'Chargement de vos rapports enregistrés...',
      'errorLoadingSavedReports': 'Erreur lors du chargement des rapports enregistrés',
      'noSavedReportsYet': 'Aucun rapport enregistré pour le moment',
      'browseAndSaveReports': 'Parcourez les rapports et appuyez sur l\'icône de signet pour les enregistrer ici.',
      'browseReports': 'Parcourir les rapports',
      'termsOfService': 'Conditions d\'utilisation',
      'aboutApp': 'À propos de l\'application',
      'helpAndSupport': 'Aide et Support',
      'feedback': 'Retour d\'information',
      'deleteAccountConfirmationTitle': 'Supprimer le compte',
      'deleteAccountConfirmationContent': 'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
      'suggestion': 'Suggestion',
      'other': 'Autre',
      'inAppMessage': 'Message dans l\'application',
      'doNotContactMe': 'Ne pas me contacter',
      'verifiedPhoneFromProfile': 'Ceci est le numéro de téléphone vérifié de votre profil.',
      'pleaseSelectIncidentDate': 'Veuillez sélectionner la date de l\'incident.',
      'pleaseFillRequiredFields': 'Veuillez remplir tous les champs requis et corriger les erreurs.',
      'similarReportFound': 'Rapport similaire trouvé',
      'similarReportDescription': 'Un rapport avec des détails très similaires existe déjà dans notre système. Veuillez l\'examiner pour éviter de créer un doublon.',
      // 'otherSimilarReportsFound': '+{count} autres rapports similaires trouvés.',
      'viewExistingReport': 'Voir le rapport existant',
      'report': 'Rapport',
      'details': 'Détails',
      'ownerNameRequired': 'Nom du propriétaire (ou nom sur l\'objet)*',
      'pleaseEnterOwnerName': 'Veuillez entrer le nom du propriétaire ou le nom sur l\'objet',
      'pleaseSelectCategory': 'Veuillez sélectionner une catégorie',
      'subcategory': 'Sous-catégorie',
      'pleaseSelectSubcategory': 'Veuillez sélectionner une sous-catégorie',
      'selectCategoryFirst': 'Sélectionnez d\'abord une catégorie',
      'incidentDate': 'Date de l\'incident',
      'selectDate': 'Sélectionner la date',
      'mainLocation': 'Emplacement principal',
      'pleaseSelectMainLocation': 'Veuillez sélectionner un emplacement principal',
      'subLocation': 'Sous-emplacement',
      'pleaseSelectSubLocation': 'Veuillez sélectionner un sous-emplacement',
      'selectMainLocationFirst': 'Sélectionnez d\'abord un emplacement principal',
      'additionalNotesOptional': 'Notes supplémentaires (optionnel)',
      'enterExtraInformation': 'Entrez ici toute information supplémentaire...',
      'offerReward': 'Offrir une récompense ?',
      'rewardAmountXAF': 'Montant de la récompense (XAF)',
      'pleaseEnterRewardAmount': 'Veuillez entrer le montant de la récompense',
      'pleaseEnterValidNumber': 'Veuillez entrer un nombre valide',
      'amountMustBeGreaterThanZero': 'Le montant doit être supérieur à zéro',
      'nextContactInformation': 'SUIVANT: Informations de contact',
      'resetFormToOriginal': 'Réinitialiser le formulaire à l\'original',
      'summary': 'Résumé',
      'reviewReportDetails': 'Veuillez examiner attentivement les détails de votre rapport avant de le soumettre.',
      'itemDetails': 'Détails de l\'objet',
      'type': 'Type',
      'ownerName': 'Nom du propriétaire',
      'notAvailable': 'N/A',
      'category': 'Catégorie',
      'location': 'Emplacement',
      'additionalNotes': 'Notes supplémentaires',
      'images': 'Images',
      'rewardOffered': 'Récompense offerte',
      'amount': 'Montant',
      'updatingReport': 'Mise à jour du rapport...',
      'submittingReport': 'Soumission du rapport...',
      'reportUpdated': 'Rapport mis à jour !',
      'reportSubmitted': 'Rapport soumis !',
      'confirmAndUpdateReport': 'Confirmer et mettre à jour le rapport',
      'confirmAndSubmitReport': 'Confirmer et soumettre le rapport',
      'updatingYourReport': 'Mise à jour de votre rapport...',
      'submittingYourReport': 'Soumission de votre rapport...',
      'pleaseDoNotCloseApp': 'Veuillez ne pas fermer l\'application ou naviguer ailleurs.',
      'submissionInProgress': 'Soumission en cours',
      'submissionInProgressDescription': 'Votre rapport est actuellement en cours de traitement. Veuillez attendre que la soumission soit terminée.',
      
      // Notifications page translations
      'deleteClaimTitle': 'Supprimer la réclamation',
      'deleteClaimConfirm': 'Êtes-vous sûr de vouloir supprimer cette réclamation ? Cette action est irréversible.',
      'signInRequired': 'Connexion requise',
      'signInToViewNotifications': 'Veuillez vous connecter pour voir vos notifications.',
      'errorLoading': 'Erreur de chargement',
      'tryAgain': 'Réessayer',
      'noNotifications': 'Aucune notification',
      'noNotificationsSubtitle': 'Vous n\'avez pas encore de notifications. Elles apparaîtront ici lorsque vous recevrez des réclamations ou des mises à jour de statut.',
      
      // SimpleCard and ReportDetails translations
      'resolved': 'RÉSOLU',
      'reported': 'Signalé',
      'ago': 'il y a',
      'editReport': 'Modifier le rapport',
      'markAsActive': 'Marquer comme actif',
      'markAsResolved': 'Marquer comme résolu',
      'deleteReport': 'Supprimer le rapport',
      'unsaveReport': 'Ne plus sauvegarder',
      'saveReport': 'Sauvegarder le rapport',
      // 'moreOptions': 'Plus d\'options',
      'options': 'Options',
      'basicInformation': 'Informations de base',
      'documentOwner': 'Propriétaire du document',
      'locationAndDates': 'Lieu et dates',
      'reportedOn': 'Signalé le',
      // 'additionalNotes': 'Notes supplémentaires',
      // 'images': 'Images',
      'allImages': 'Toutes les images',
      'main': 'Principal',
      'imageNotAvailable': 'Image non disponible',
      'youCreatedThisReport': 'Vous avez créé ce rapport',
      'saved': 'Sauvegardé',
      // 'save': 'Sauvegarder',
      'claimThisReport': 'Réclamer ce rapport',
      'alreadyClaimed': 'Déjà réclamé',
      'alreadyClaimedMessage': 'Vous avez déjà soumis une réclamation pour ce rapport.',
      'shareReport': 'Partager le rapport',
      'pleaseSignInToSave': 'Veuillez vous connecter pour sauvegarder les rapports',
      'cannotSaveOwnReport': 'Vous ne pouvez pas sauvegarder votre propre rapport. Consultez vos rapports dans la section \'Mes rapports\'.',
      'reportSaved': 'Rapport sauvegardé !',
      'reportRemoved': 'Rapport supprimé',
      'failedToSave': 'Échec de la sauvegarde : {error}',
      'pleaseVerifyPhoneToShare': 'Veuillez vérifier votre numéro de téléphone pour partager ce rapport',
      'failedToShare': 'Échec du partage : {error}',
      'couldNotLaunch': 'Impossible de lancer {url}',
      'cannotClaimOwnReport': 'Vous ne pouvez pas réclamer votre propre rapport.',
      'pleaseSignInToContinue': 'Veuillez vous connecter pour continuer.',
      'pleaseCompleteProfile': 'Veuillez compléter votre profil pour continuer.',
      'claimSent': 'Réclamation envoyée ! Le propriétaire examinera votre message et vos images.',
      'claimItem': 'Réclamer l\'objet {type}',
      'provideProofFound': 'Fournissez une preuve que vous avez trouvé cet objet',
      'provideProofBelongs': 'Fournissez une preuve que cet objet vous appartient',
      'message': 'Message',
      'describeHowFound': 'Décrivez comment vous avez trouvé l\'objet...',
      'describeItemAndProof': 'Décrivez l\'objet et fournissez une preuve...',
      'tooLong': 'Trop long',
      'minChars': 'Min {count} caractères',
      'imagesRequired': 'Images *Requis',
      'imagesOptional': 'Images (Optionnel)',
      'gallery': 'Galerie',
      'camera': 'Caméra',
      'submitClaim': 'Soumettre la réclamation',
      'submitting': 'Soumission...',
      'confirmClaim': 'Confirmer la réclamation',
      'submitClaimForItem': 'Soumettre une réclamation pour l\'objet {type} ?',
      'maximumImagesAllowed': 'Maximum {count} images autorisées',
      'failedToPickImages': 'Échec de la sélection d\'images : {error}',
      'failedToTakePhoto': 'Échec de la prise de photo : {error}',
      'pleaseEnterMinChars': 'Veuillez entrer au moins {count} caractères',
      'pleaseSelectImageForLost': 'Veuillez sélectionner au moins une image pour les réclamations d\'objets perdus',
      'failedToSubmitClaim': 'Échec de la soumission de la réclamation : {error}',
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
  String otherSimilarReportsFound(int count) => _localizedValues[locale.languageCode]?['otherSimilarReportsFound']?.replaceAll('{count}', count.toString()) ?? '+$count other similar reports found.';

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
  String get confirmUnsave => _localizedValues[locale.languageCode]?['confirmUnsave'] ?? 'Confirm Unsave';
  String get confirmUnsaveDescription => _localizedValues[locale.languageCode]?['confirmUnsaveDescription'] ?? 'Are you sure you want to remove this report from your saved items?';
  String get unsave => _localizedValues[locale.languageCode]?['unsave'] ?? 'Unsave';
  String get mySavedReportsTitle => _localizedValues[locale.languageCode]?['mySavedReportsTitle'] ?? 'My Saved Reports';
  String get logInToViewSaved => _localizedValues[locale.languageCode]?['logInToViewSaved'] ?? 'Please log in to view your saved reports.';
  String get loadingSavedReports => _localizedValues[locale.languageCode]?['loadingSavedReports'] ?? 'Loading your saved reports...';
  String get errorLoadingSavedReports => _localizedValues[locale.languageCode]?['errorLoadingSavedReports'] ?? 'Error loading saved reports';
  String get noSavedReportsYet => _localizedValues[locale.languageCode]?['noSavedReportsYet'] ?? 'No saved reports yet';
  String get browseAndSaveReports => _localizedValues[locale.languageCode]?['browseAndSaveReports'] ?? 'Browse reports and tap the bookmark icon to save them here.';
  String get browseReports => _localizedValues[locale.languageCode]?['browseReports'] ?? 'Browse Reports';
  String get notSet => _localizedValues[locale.languageCode]?['notSet'] ?? 'Not Set';
  String get signInToManageProfile => _localizedValues[locale.languageCode]?['signInToManageProfile'] ?? 'Sign in to manage profile';
  String get noPhoneNumberSet => _localizedValues[locale.languageCode]?['noPhoneNumberSet'] ?? 'No phone number set';
  String get notificationsEnabled => _localizedValues[locale.languageCode]?['notificationsEnabled'] ?? 'Notifications enabled';
  String get notificationsDisabled => _localizedValues[locale.languageCode]?['notificationsDisabled'] ?? 'Notifications disabled';
  String get phoneManagement => _localizedValues[locale.languageCode]?['phoneManagement'] ?? 'Phone Management';
  String get yourProfileIsAlreadyVerified => _localizedValues[locale.languageCode]?['yourProfileIsAlreadyVerified'] ?? 'Your profile is already verified';
  String get themeSetTo => _localizedValues[locale.languageCode]?['themeSetTo'] ?? 'Theme set to';
  String get termsOfService => _localizedValues[locale.languageCode]?['termsOfService'] ?? 'Terms of Service';
  String get aboutApp => _localizedValues[locale.languageCode]?['aboutApp'] ?? 'About App';
  String get helpAndSupport => _localizedValues[locale.languageCode]?['helpAndSupport'] ?? 'Help & Support';
  String get feedback => _localizedValues[locale.languageCode]?['feedback'] ?? 'Feedback';
  String get deleteAccountConfirmationTitle => _localizedValues[locale.languageCode]?['deleteAccountConfirmationTitle'] ?? 'Delete Account';
  String get deleteAccountConfirmationContent => _localizedValues[locale.languageCode]?['deleteAccountConfirmationContent'] ?? 'Are you sure you want to delete your account? This action cannot be undone.';
  String get suggestion => _localizedValues[locale.languageCode]?['suggestion'] ?? 'Suggestion';
  String get other => _localizedValues[locale.languageCode]?['other'] ?? 'Other';
  String get inAppMessage => _localizedValues[locale.languageCode]?['inAppMessage'] ?? 'In-app Message';
  String get doNotContactMe => _localizedValues[locale.languageCode]?['doNotContactMe'] ?? 'Do not contact me';
  String get verifiedPhoneFromProfile => _localizedValues[locale.languageCode]?['verifiedPhoneFromProfile'] ?? 'This is the verified phone number from your profile.';
  String get pleaseSelectIncidentDate => _localizedValues[locale.languageCode]?['pleaseSelectIncidentDate'] ?? 'Please select the incident date.';
  String get pleaseFillRequiredFields => _localizedValues[locale.languageCode]?['pleaseFillRequiredFields'] ?? 'Please fill in all required fields and fix errors.';
  String get similarReportFound => _localizedValues[locale.languageCode]?['similarReportFound'] ?? 'Similar Report Found';
  String get similarReportDescription => _localizedValues[locale.languageCode]?['similarReportDescription'] ?? 'A report with very similar details already exists in our system. Please review it to avoid creating a duplicate.';
  String get viewExistingReport => _localizedValues[locale.languageCode]?['viewExistingReport'] ?? 'View Existing Report';
  String get report => _localizedValues[locale.languageCode]?['report'] ?? 'Report';
  String get details => _localizedValues[locale.languageCode]?['details'] ?? 'Details';
  String get ownerNameRequired => _localizedValues[locale.languageCode]?['ownerNameRequired'] ?? 'Owner\'s Name (or Name on Item)*';
  String get pleaseEnterOwnerName => _localizedValues[locale.languageCode]?['pleaseEnterOwnerName'] ?? 'Please enter the owner\'s name or name on the item';
  String get pleaseSelectCategory => _localizedValues[locale.languageCode]?['pleaseSelectCategory'] ?? 'Please select a category';
  String get subcategory => _localizedValues[locale.languageCode]?['subcategory'] ?? 'Subcategory';
  String get pleaseSelectSubcategory => _localizedValues[locale.languageCode]?['pleaseSelectSubcategory'] ?? 'Please select a subcategory';
  String get selectCategoryFirst => _localizedValues[locale.languageCode]?['selectCategoryFirst'] ?? 'Select a category first';
  String get incidentDate => _localizedValues[locale.languageCode]?['incidentDate'] ?? 'Incident Date';
  String get selectDate => _localizedValues[locale.languageCode]?['selectDate'] ?? 'Select Date';
  String get mainLocation => _localizedValues[locale.languageCode]?['mainLocation'] ?? 'Main Location';
  String get pleaseSelectMainLocation => _localizedValues[locale.languageCode]?['pleaseSelectMainLocation'] ?? 'Please select a main location';
  String get subLocation => _localizedValues[locale.languageCode]?['subLocation'] ?? 'Sub-Location';
  String get pleaseSelectSubLocation => _localizedValues[locale.languageCode]?['pleaseSelectSubLocation'] ?? 'Please select a sub-location';
  String get selectMainLocationFirst => _localizedValues[locale.languageCode]?['selectMainLocationFirst'] ?? 'Select a main location first';
  String get additionalNotesOptional => _localizedValues[locale.languageCode]?['additionalNotesOptional'] ?? 'Additional Notes (Optional)';
  String get enterExtraInformation => _localizedValues[locale.languageCode]?['enterExtraInformation'] ?? 'Enter any extra information here...';
  String get offerReward => _localizedValues[locale.languageCode]?['offerReward'] ?? 'Offer Reward?';
  String get rewardAmountXAF => _localizedValues[locale.languageCode]?['rewardAmountXAF'] ?? 'Reward Amount (XAF)';
  String get pleaseEnterRewardAmount => _localizedValues[locale.languageCode]?['pleaseEnterRewardAmount'] ?? 'Please enter the reward amount';
  String get pleaseEnterValidNumber => _localizedValues[locale.languageCode]?['pleaseEnterValidNumber'] ?? 'Please enter a valid number';
  String get amountMustBeGreaterThanZero => _localizedValues[locale.languageCode]?['amountMustBeGreaterThanZero'] ?? 'Amount must be greater than zero';
  String get nextContactInformation => _localizedValues[locale.languageCode]?['nextContactInformation'] ?? 'NEXT: Contact Information';
  String get resetFormToOriginal => _localizedValues[locale.languageCode]?['resetFormToOriginal'] ?? 'Reset Form to Original';
  String get summary => _localizedValues[locale.languageCode]?['summary'] ?? 'Summary';
  String get reviewReportDetails => _localizedValues[locale.languageCode]?['reviewReportDetails'] ?? 'Please review your report details carefully before submitting.';
  String get itemDetails => _localizedValues[locale.languageCode]?['itemDetails'] ?? 'Item Details';
  String get type => _localizedValues[locale.languageCode]?['type'] ?? 'Type';
  String get ownerName => _localizedValues[locale.languageCode]?['ownerName'] ?? 'Owner Name';
  String get notAvailable => _localizedValues[locale.languageCode]?['notAvailable'] ?? 'N/A';
  String get category => _localizedValues[locale.languageCode]?['category'] ?? 'Category';
  String get location => _localizedValues[locale.languageCode]?['location'] ?? 'Location';
  String get additionalNotes => _localizedValues[locale.languageCode]?['additionalNotes'] ?? 'Additional Notes';
  String get images => _localizedValues[locale.languageCode]?['images'] ?? 'Images';
  String get rewardOffered => _localizedValues[locale.languageCode]?['rewardOffered'] ?? 'Reward Offered';
  String get amount => _localizedValues[locale.languageCode]?['amount'] ?? 'Amount';
  String get updatingReport => _localizedValues[locale.languageCode]?['updatingReport'] ?? 'Updating Report...';
  String get submittingReport => _localizedValues[locale.languageCode]?['submittingReport'] ?? 'Submitting Report...';
  String get reportUpdated => _localizedValues[locale.languageCode]?['reportUpdated'] ?? 'Report Updated!';
  String get reportSubmitted => _localizedValues[locale.languageCode]?['reportSubmitted'] ?? 'Report Submitted!';
  String get confirmAndUpdateReport => _localizedValues[locale.languageCode]?['confirmAndUpdateReport'] ?? 'Confirm and Update Report';
  String get confirmAndSubmitReport => _localizedValues[locale.languageCode]?['confirmAndSubmitReport'] ?? 'Confirm and Submit Report';
  String get updatingYourReport => _localizedValues[locale.languageCode]?['updatingYourReport'] ?? 'Updating your report...';
  String get submittingYourReport => _localizedValues[locale.languageCode]?['submittingYourReport'] ?? 'Submitting your report...';
  String get pleaseDoNotCloseApp => _localizedValues[locale.languageCode]?['pleaseDoNotCloseApp'] ?? 'Please do not close the app or navigate away.';
  String get submissionInProgress => _localizedValues[locale.languageCode]?['submissionInProgress'] ?? 'Submission in Progress';
  String get submissionInProgressDescription => _localizedValues[locale.languageCode]?['submissionInProgressDescription'] ?? 'Your report is currently being processed. Please wait for the submission to complete.';
  
  // Notifications page getters
  String get deleteClaimTitle => _localizedValues[locale.languageCode]?['deleteClaimTitle'] ?? 'Delete Claim';
  String get deleteClaimConfirm => _localizedValues[locale.languageCode]?['deleteClaimConfirm'] ?? 'Are you sure you want to delete this claim? This action cannot be undone.';
  String get signInRequired => _localizedValues[locale.languageCode]?['signInRequired'] ?? 'Sign In Required';
  String get signInToViewNotifications => _localizedValues[locale.languageCode]?['signInToViewNotifications'] ?? 'Please sign in to view your notifications.';
  String get errorLoading => _localizedValues[locale.languageCode]?['errorLoading'] ?? 'Error Loading';
  String get tryAgain => _localizedValues[locale.languageCode]?['tryAgain'] ?? 'Try Again';
  String get noNotifications => _localizedValues[locale.languageCode]?['noNotifications'] ?? 'No Notifications';
  String get noNotificationsSubtitle => _localizedValues[locale.languageCode]?['noNotificationsSubtitle'] ?? 'You don\'t have any notifications yet. They will appear here when you receive claims or status updates.';

  String get failedToSubmitClaim => _localizedValues[locale.languageCode]?['failedToSubmitClaim'] ?? 'Failed to submit claim: {error}';
  
  // SimpleCard and ReportDetails getters
  String get resolved => _localizedValues[locale.languageCode]?['resolved'] ?? 'RESOLVED';
  String get reported => _localizedValues[locale.languageCode]?['reported'] ?? 'Reported';
  String get ago => _localizedValues[locale.languageCode]?['ago'] ?? 'ago';
  String get editReport => _localizedValues[locale.languageCode]?['editReport'] ?? 'Edit Report';
  String get markAsActive => _localizedValues[locale.languageCode]?['markAsActive'] ?? 'Mark as Active';
  String get markAsResolved => _localizedValues[locale.languageCode]?['markAsResolved'] ?? 'Mark as Resolved';
  String get deleteReport => _localizedValues[locale.languageCode]?['deleteReport'] ?? 'Delete Report';
  String get unsaveReport => _localizedValues[locale.languageCode]?['unsaveReport'] ?? 'Unsave Report';
  String get saveReport => _localizedValues[locale.languageCode]?['saveReport'] ?? 'Save Report';
  // String get moreOptions => _localizedValues[locale.languageCode]?['moreOptions'] ?? 'More options';
  String get options => _localizedValues[locale.languageCode]?['options'] ?? 'Options';
  String get basicInformation => _localizedValues[locale.languageCode]?['basicInformation'] ?? 'Basic Information';
  String get documentOwner => _localizedValues[locale.languageCode]?['documentOwner'] ?? 'Document Owner';
  String get locationAndDates => _localizedValues[locale.languageCode]?['locationAndDates'] ?? 'Location & Dates';
  // String get incidentDate => _localizedValues[locale.languageCode]?['incidentDate'] ?? 'Incident Date';
  String get reportedOn => _localizedValues[locale.languageCode]?['reportedOn'] ?? 'Reported On';
  // String get additionalNotes => _localizedValues[locale.languageCode]?['additionalNotes'] ?? 'Additional Notes';
  // String get images => _localizedValues[locale.languageCode]?['images'] ?? 'Images';
  String get allImages => _localizedValues[locale.languageCode]?['allImages'] ?? 'All Images';
  String get main => _localizedValues[locale.languageCode]?['main'] ?? 'Main';
  String get imageNotAvailable => _localizedValues[locale.languageCode]?['imageNotAvailable'] ?? 'Image not available';
  String get youCreatedThisReport => _localizedValues[locale.languageCode]?['youCreatedThisReport'] ?? 'You created this report';
  String get saved => _localizedValues[locale.languageCode]?['saved'] ?? 'Saved';
  // String get save => _localizedValues[locale.languageCode]?['save'] ?? 'Save';
  String get claimThisReport => _localizedValues[locale.languageCode]?['claimThisReport'] ?? 'Claim this report';
  String get alreadyClaimed => _localizedValues[locale.languageCode]?['alreadyClaimed'] ?? 'Already Claimed';
  String get alreadyClaimedMessage => _localizedValues[locale.languageCode]?['alreadyClaimedMessage'] ?? 'You have already submitted a claim for this report.';
  String get shareReport => _localizedValues[locale.languageCode]?['shareReport'] ?? 'Share Report';
  String get pleaseSignInToSave => _localizedValues[locale.languageCode]?['pleaseSignInToSave'] ?? 'Please sign in to save reports';
  String get cannotSaveOwnReport => _localizedValues[locale.languageCode]?['cannotSaveOwnReport'] ?? 'You can\'t save your own report. View your reports in the \'My Reports\' section.';
  String get reportSaved => _localizedValues[locale.languageCode]?['reportSaved'] ?? 'Report saved!';
  String get reportRemoved => _localizedValues[locale.languageCode]?['reportRemoved'] ?? 'Report removed';
  String get pleaseVerifyPhoneToShare => _localizedValues[locale.languageCode]?['pleaseVerifyPhoneToShare'] ?? 'Please verify your phone number to share this report';
  String get couldNotLaunch => _localizedValues[locale.languageCode]?['couldNotLaunch'] ?? 'Could not launch {url}';
  String get cannotClaimOwnReport => _localizedValues[locale.languageCode]?['cannotClaimOwnReport'] ?? 'You cannot claim your own report.';
  String get pleaseSignInToContinue => _localizedValues[locale.languageCode]?['pleaseSignInToContinue'] ?? 'Please sign in to continue.';
  String get pleaseCompleteProfile => _localizedValues[locale.languageCode]?['pleaseCompleteProfile'] ?? 'Please complete your profile to continue.';
  String get claimSent => _localizedValues[locale.languageCode]?['claimSent'] ?? 'Claim sent! The owner will review your message and images.';
  String get provideProofFound => _localizedValues[locale.languageCode]?['provideProofFound'] ?? 'Provide proof that you found this item';
  String get provideProofBelongs => _localizedValues[locale.languageCode]?['provideProofBelongs'] ?? 'Provide proof that this item belongs to you';
  String get message => _localizedValues[locale.languageCode]?['message'] ?? 'Message';
  String get describeHowFound => _localizedValues[locale.languageCode]?['describeHowFound'] ?? 'Describe how you found the item...';
  String get describeItemAndProof => _localizedValues[locale.languageCode]?['describeItemAndProof'] ?? 'Describe the item and provide proof...';
  String get tooLong => _localizedValues[locale.languageCode]?['tooLong'] ?? 'Too long';
  String get imagesRequired => _localizedValues[locale.languageCode]?['imagesRequired'] ?? 'Images *Required';
  String get imagesOptional => _localizedValues[locale.languageCode]?['imagesOptional'] ?? 'Images (Optional)';
  String get gallery => _localizedValues[locale.languageCode]?['gallery'] ?? 'Gallery';
  String get camera => _localizedValues[locale.languageCode]?['camera'] ?? 'Camera';
  String get submitClaim => _localizedValues[locale.languageCode]?['submitClaim'] ?? 'Submit Claim';
  String get submitting => _localizedValues[locale.languageCode]?['submitting'] ?? 'Submitting...';
  String get confirmClaim => _localizedValues[locale.languageCode]?['confirmClaim'] ?? 'Confirm Claim';
  
  // Parameterized methods for SimpleCard and ReportDetails
  String failedToSave(String error) => _localizedValues[locale.languageCode]?['failedToSave']?.replaceAll('{error}', error) ?? 'Failed to save: $error';
  String failedToShare(String error) => _localizedValues[locale.languageCode]?['failedToShare']?.replaceAll('{error}', error) ?? 'Failed to share: $error';
  String couldNotLaunchUrl(String url) => _localizedValues[locale.languageCode]?['couldNotLaunch']?.replaceAll('{url}', url) ?? 'Could not launch $url';
  String claimItem(String type) => _localizedValues[locale.languageCode]?['claimItem']?.replaceAll('{type}', type) ?? 'Claim $type Item';
  String minChars(int count) => _localizedValues[locale.languageCode]?['minChars']?.replaceAll('{count}', count.toString()) ?? 'Min $count chars';
  String submitClaimForItem(String type) => _localizedValues[locale.languageCode]?['submitClaimForItem']?.replaceAll('{type}', type) ?? 'Submit claim for $type item?';
  String maximumImagesAllowed(int count) => _localizedValues[locale.languageCode]?['maximumImagesAllowed']?.replaceAll('{count}', count.toString()) ?? 'Maximum $count images allowed';
  String failedToPickImages(String error) => _localizedValues[locale.languageCode]?['failedToPickImages']?.replaceAll('{error}', error) ?? 'Failed to pick images: $error';
  String failedToTakePhoto(String error) => _localizedValues[locale.languageCode]?['failedToTakePhoto']?.replaceAll('{error}', error) ?? 'Failed to take photo: $error';
  String pleaseEnterMinChars(int count) => _localizedValues[locale.languageCode]?['pleaseEnterMinChars']?.replaceAll('{count}', count.toString()) ?? 'Please enter at least $count characters';
  // String failedToSubmitClaim(String error) => _localizedValues[locale.languageCode]?['failedToSubmitClaim']?.replaceAll('{error}', error) ?? 'Failed to submit claim: $error';
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