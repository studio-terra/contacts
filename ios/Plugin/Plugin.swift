//
//  Plugin.swift
//
//
//  Created by Jonathan Gerber on 15.02.20.
//  Copyright © 2020 Byrds & Bytes GmbH. All rights reserved.

import Foundation
import Capacitor
import Contacts


@objc(ContactsPlugin)
public class ContactsPlugin: CAPPlugin {

    @objc func getPermissions(_ call: CAPPluginCall) {
        print("checkPermission was triggered in Swift")
        Permissions.contactPermission { granted in
            switch granted {
            case true:
                call.success([
                    "granted": true
                ])
            default:
                call.success([
                    "granted": false
                ])
                }
            }
    }

    @objc func getContacts(_ call: CAPPluginCall) {        var contactsArray : [PluginResultData] = [];
        Permissions.contactPermission { granted in
            if granted {
                do {
                    let contacts = try Contacts.getContactFromCNContact(call)

                    for contact in contacts {
                        if let hasPhone = call.getBool("hasPhone") {
                            if hasPhone {
                                // If hasPhone is specified and it is set to true,
                                // Ignore all contascts that do ot have any phone numbers
                                if contact.phoneNumbers.isEmpty {
                                    continue
                                }
                            } else {
                                // If hasPhone is specified and it is set to false,
                                // Ignore all contascts that have phone number
                                if !contact.phoneNumbers.isEmpty {
                                    continue
                                }
                            }
                        }

                        var contactResult: PluginResultData = [
                            "contactId": contact.identifier,
                            "displayName": "\(contact.givenName) \(contact.familyName)",
                        ]

                        var phoneNumbers: [PluginResultData] = []
                        var emails: [PluginResultData] = []
                        

                        if contact.isKeyAvailable(CNContactPhoneNumbersKey) {
                            for number in contact.phoneNumbers {
                                let numberToAppend = number.value.stringValue
                                let label = number.label ?? ""
                                let labelToAppend = CNLabeledValue<CNPhoneNumber>.localizedString(forLabel: label)
                                phoneNumbers.append([
                                    "label": labelToAppend,
                                    "number": numberToAppend
                                ])
                                print(phoneNumbers)
                            }
                            contactResult["phoneNumbers"] = phoneNumbers
                        }

                        if contact.isKeyAvailable(CNContactEmailAddressesKey) {
                            for email in contact.emailAddresses {
                                let emailToAppend = email.value as String
                                let label = email.label ?? ""
                                let labelToAppend = CNLabeledValue<NSString>.localizedString(forLabel: label)
                                emails.append([
                                    "label": labelToAppend,
                                    "address": emailToAppend
                                ])
                            }
                            contactResult["emails"] = emails
                        }

                        if contact.isKeyAvailable(CNContactThumbnailImageDataKey), let photoThumbnail = contact.thumbnailImageData {
                            contactResult["photoThumbnail"] = "data:image/png;base64,\(photoThumbnail.base64EncodedString())"
                        }

                        if contact.isKeyAvailable(CNContactBirthdayKey), let birthday = contact.birthday?.date {
                            let dateFormatter = DateFormatter()
                            // You must set the time zone from your default time zone to UTC +0,
                            // which is what birthdays in Contacts are set to.
                            dateFormatter.timeZone = TimeZone(identifier: "UTC")
                            dateFormatter.dateFormat = "YYYY-MM-dd"
                               
                            contactResult["birthday"] = dateFormatter.string(from: birthday)
                        }

                        if contact.isKeyAvailable(CNContactOrganizationNameKey), let includeOrganization = call.getBool("includeOrganization") {
                            if includeOrganization && !contact.organizationName.isEmpty {
                                contactResult["organizationName"] = contact.organizationName
                            }
                        }

                        if contact.isKeyAvailable(CNContactJobTitleKey), let includeOrganization = call.getBool("includeOrganization") {
                            if includeOrganization && !contact.jobTitle.isEmpty {
                                contactResult["organizationRole"] = contact.jobTitle
                            }
                        }

                        contactsArray.append(contactResult)
                    }
                    call.success([
                        "contacts": contactsArray
                    ])
                } catch let error as NSError {
                    call.error("Generic Error", error)
                }
            } else {
                call.error("User denied access to contacts")
            }
        }
    }

}

