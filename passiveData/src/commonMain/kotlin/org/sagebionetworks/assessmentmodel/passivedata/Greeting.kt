package org.sagebionetworks.assessmentmodel.passivedata

class Greeting {
    fun greeting(): String {
        return "Hello, ${Platform().platform}!"
    }
}