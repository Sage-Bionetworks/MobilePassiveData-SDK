object Versions {

    const val assessmentVersion = "0.4.4"

    const val kotlinxDateTime = "0.2.0"

    const val kotlin = "1.4.32"
    const val kotlinxSerializationJson = "1.1.0"
}

object Deps {
    object KotlinX {
        val dateTime = "org.jetbrains.kotlinx:kotlinx-datetime:${Versions.kotlinxDateTime}"
        val serializationJson =
            "org.jetbrains.kotlinx:kotlinx-serialization-json:${Versions.kotlinxSerializationJson}"
    }

    object AssessmentModel {
        val sdk =
            "org.sagebionetworks.assessmentmodel:assessmentModel:${Versions.assessmentVersion}"
    }
}
