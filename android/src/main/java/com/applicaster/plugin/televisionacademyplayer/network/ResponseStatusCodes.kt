package com.applicaster.tvaplayerhook.enums

enum class ResponseStatusCodes(val value: Int) {
    SUCCESS(200),
    INVALID_REQUEST(400),
    AUTHENTICATION_FAILED(401),
    NOT_AUTHORIZED(403),
    NO_SUCH_CONTENT(404),
    ON_FAILURE_NO_CODE(-1);


    companion object {

        fun getData(data: Int): ResponseStatusCodes = values().first{it.value == data}
    }

}