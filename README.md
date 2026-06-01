

### Opening

"Good day everyone. Today I'll walk you through the main errors and bugs we encountered while building ML Advisor, and how we fixed them. We ran into about a dozen significant issues during development. I'll focus on the most interesting ones."

---

### Firebase Analytics Bug

"The first major bug was in the admin analytics. When we first implemented the stats dashboard, the app crashed every time an admin tried to view it. The error said something about `docs not defined` on an `AggregateQuerySnapshot`.

I thought I had imported the wrong Firestore package. But after reading the error carefully, I realized the problem was the `.count()` method. I had written `_db.collection('models').count().get()` thinking it would give me a count and also let me access the documents. It doesn't work that way. `.count()` returns a special object that only knows the number, not the actual documents.

The fix was simple once I understood it. Instead of using `.count()`, I just used `.get()` and then checked the length of the docs array. So `results[0].docs.length` instead of `results[0].count`. This took about 20 minutes to figure out, but it taught me something important about how Firestore queries work."

---

### Missing Update Methods

"The next set of errors came when we added edit functionality to the admin dashboard. We had added edit buttons for models, papers, and glossary terms, but when we clicked save, the app crashed again.

The terminal showed errors saying `updatePaper` and `updateGlossaryTerm` weren't defined in the FirestoreService class. I had completely forgotten to write those methods. I had only written add and delete methods, but not update.

The fix was straightforward. I opened the Firestore service file and added two methods. One for updating papers, one for updating glossary terms. Each method just calls `.doc(id).update()` on the Firestore collection. Once I added those, the edit dialogs worked perfectly. This was a silly oversight on my part. I should have written all the CRUD methods at once instead of piece by piece."

---

### Flutter Doctor Setup Issues

"Earlier in the project, before we even wrote any code, we had setup problems. Several team members ran `flutter doctor` and saw red X's. The main issue was Android Studio and Android SDK not being properly installed.

One team member hadn't accepted the Android licenses. The terminal told him to run `flutter doctor --android-licenses`, but he didn't know that command existed. Once we ran that and accepted all the licenses by pressing 'y' repeatedly, the red X went away.

Another team member had Flutter installed but the path wasn't set correctly. When they typed `flutter` in the terminal, nothing happened. We had to add the Flutter bin folder to their system PATH variable. This is a common issue with first-time Flutter installations."

---

### The Models Not Loading Bug

"A more interesting bug was that the app always showed the same eight models, even when we added new ones through the admin panel. I couldn't understand why. I knew the add model form was writing to Firestore because I could see the new documents in the Firebase console.

The problem was in the ModelProvider. The `loadModels` method always fell back to hardcoded default data if anything went wrong. And something was going wrong. The `getModels` method was throwing an exception, but we weren't logging it anywhere, so we didn't know what was happening.

After adding print statements, I discovered that the Firestore collection didn't have any documents initially. So `getModels` returned an empty list, which triggered the fallback data. But even after we added documents, the app still used fallback data because the exception kept happening. The real issue was that the `MlModel.fromJson` method expected field names like `f1Score` but Firestore had `f1_score` with an underscore.

We fixed this by updating the `fromJson` method to check for both naming conventions. If `json['f1Score']` is null, try `json['f1_score']`. We did this for all the metrics fields. After that, the app started reading from Firestore correctly. This one bug took about an hour to track down."

---

### Merge Conflicts with Git

"Working remotely as a team, we had some Git issues. The biggest one was a merge conflict in `pubspec.yaml`. Two team members had added different dependencies on different branches. When we tried to merge, Git didn't know which version to keep.

The fix was to manually open the file, look for the conflict markers - those are the angle brackets and equals signs that Git adds. We removed the markers and kept both sets of dependencies. After that, we committed the resolved file and the merge completed.

This taught us to communicate better about which files we're working on. We started using a file ownership system. One person owned models, another owned providers, another owned screens. This prevented most conflicts."

---

### Chat Feature Connection Issues

"The AI chat feature gave us connection problems. When users typed a message, nothing happened. No response, no error message, just nothing.

The issue was that the Flutter app was trying to connect to `localhost:8000`, but on an Android emulator, `localhost` means the emulator itself, not the host computer. The emulator couldn't find our FastAPI backend.

The fix was to change the base URL in `constants.dart` from `http://localhost:8000` to `http://10.0.2.2:8000` for Android emulators. That special IP address tells the emulator to connect to the host computer's localhost. For iOS simulators and physical devices, we kept the original localhost address.

We also added a note in the documentation so team members know to change the URL based on what device they're testing on."

---

### The Favorites Disappearing Bug

"Another bug that confused users was that favorites would disappear after logging out and back in. The heart icon would show correctly while logged in, but after restarting the app, all saved favorites were gone.

I realized that favorites were being stored in the provider's memory, but not being reloaded from Firestore when the app started. The `loadFavorites` method existed, but it wasn't being called after login.

The fix was to call `loadFavorites` in the `initState` of the home screen, right after getting the authenticated user. We also added a call in the `login` method of the AuthProvider. Now whenever a user logs in, their favorites are fetched from Firestore and displayed correctly."

---

### Lessons Learned

"Looking back at all these errors, I learned a few things. First, always check which Firebase features are available on the free tier before using them. Second, communication between team members prevents merge conflicts and duplicate work. Third, logging errors to the console helps track down silent failures.

The biggest lesson was that reading the error message carefully - not just glancing at it - saves hours of debugging time. Every error message tells you exactly what's wrong. You just have to read it."



### Error 1: Missing Update Methods and Firebase Analytics Bug (From the Terminal Output)

“The most frustrating compilation error we had happened late in development. We had added edit buttons to the admin dashboard, but when we tried to run the app, we got four sets of errors at once.

The first two errors said `updatePaper` and `updateGlossaryTerm` weren’t defined in the FirestoreService class. I had completely forgotten to write those methods. I only had add and delete methods, but no update methods.

The other two errors were about the analytics system. I had used `count().get().docs.length` to get document counts, but `count()` returns an AggregateQuerySnapshot, which doesn’t have a `docs` property. The compiler was telling me that `docs` isn’t defined for that type.

I fixed the missing methods by adding `updatePaper` and `updateGlossaryTerm` to the Firestore service file. Each method simply calls `.doc(id).update()` on the appropriate collection. For the analytics error, I replaced `.count().get()` with just `.get()` and then used `.docs.length`. This worked perfectly on the free Firebase tier.”


### Error 2: Range Error on Profile Screen Avatar

“We also had a range error on the profile screen. The error said `Range error (index): invalid, value:valid value range is invalid empty:0`. This was happening when a user’s display name was empty. The code tried to get the first character of an empty string, which caused the crash.

The fix was to add a check before accessing the first character. We replaced the line that took the first letter of the name with a conditional that checks if the name exists and isn’t empty. If the name is valid, it uses the first letter. If not, it defaults to ‘U’ for User. This fixed the crash and handled edge cases gracefully.”


### Error 3: ModelProvider Import Missing

“Another compilation error said `’ModelProvider’ isn’t a type`. This happened in the model detail screen. The code was trying to access ModelProvider, but the import statement was missing at the top of the file.

The fix was simple – we just added `import ‘../providers/model_provider.dart’;` at the top of the model detail screen file. This error taught us to always check imports when the compiler says something isn’t a type.”


### Error 4: Multiple Compilation Failures (Theme, Constants, Service References)

“We had one big compilation error that showed multiple problems at once. The error said `theme` member not found, `_service` getter not defined, and `AppConstants` not defined.

The theme error happened because the main.dart file was using a theme called `AppWideTheme.theme` but that class didn’t exist. We had renamed our theme class to `AppTheme` but forgot to update the reference in main.dart.

The `_service` errors happened in the model provider and favorites provider. The providers were trying to access a service called `_service`, but the variable wasn’t declared. We had to add `final FirestoreService _service = FirestoreService();` at the top of each provider class.

The `AppConstants` error happened in the chat provider. The code was trying to use `AppConstants.baseUrl` to build the API URL, but the import for constants.dart was missing. We added the import and also made sure the constants class was properly exported.

These errors all came from the same issue – we had restructured our code but didn’t update all the references. We had to go through each file and check that all imports were correct and all service instances were properly initialized.”


### Error 5: The Default Flutter Template Taking Over

“The last error was more of a version control mistake. One team member accidentally committed the default Flutter counter app template to the main branch. When others pulled the latest changes, their apps reverted to the default template instead of our ML Advisor app. The Git history showed the commit with the default template content.

We fixed this by reverting to a previous commit that had our working code. We used `git reset` to go back to the commit before the bad one, then force pushed to update the remote repository. After that, everyone pulled the correct version and the app was back to normal. This taught us to always review what we’re committing and to never force push without warning the team.”

### Closing

"That's the main errors we encountered. We fixed all of them, and the app is now stable and fully functional. Thank you for listening. I'm happy to answer any questions."

---


