# Java Parser Invocation

To regenerate the golden dataset from `egypt.v2`, run:

```bash
cd vic2_economy_analyzer/vic2_economy_analyzer-master
./gradlew classes
java -cp "build/classes/java/main:build/resources/main:libs/*:$HOME/.gradle/caches/modules-2/files-2.1/com.google.code.gson/gson/2.8.9/*/gson-2.8.9.jar" \
  org.victoria2.tools.vic2sgea.export.GoldenDatasetExporterMain \
  "/tmp/file_attachments/savegames/egypt.v2" \
  "../../vc2-salesforce-version/golden-dataset/sample-game-data" \
  "../../vc2-salesforce-version/golden-dataset/sample-game-data" \
  "../../vc2-salesforce-version/golden-dataset"
```
