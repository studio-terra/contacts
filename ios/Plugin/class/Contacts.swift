//
//  Contacts.swift
//  Plugin
//
//  Created by Jonathan Gerber on 16.02.20.
//  Copyright © 2020 Byrds & Bytes GmbH. All rights reserved.
//

import Foundation
import Capacitor
import Contacts

class Contacts {
    class func getContactFromCNContact(_ call: CAPPluginCall) throws -> [CNContact] {

        let contactStore = CNContactStore()
        var keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactGivenNameKey,
            CNContactMiddleNameKey,
            CNContactFamilyNameKey,
            ] as [Any]
        let includeEmails = call.getBool("includeEmails")
        let includePhones = call.getBool("includePhones")
        let includeThumbnail = call.getBool("includeThumbnail")
        let includeBirthday = call.getBool("includeBirthday")
        let includeOrganization = call.getBool("includeOrganization")
        
        if includeEmails ?? true {
            keysToFetch.append(CNContactEmailAddressesKey)
        }

        if includePhones ?? true {
            keysToFetch.append(CNContactPhoneNumbersKey)
        }
        
        if includeThumbnail ?? true {
            keysToFetch.append(CNContactThumbnailImageDataKey)
        }
        
        if includeBirthday ?? true {
            keysToFetch.append(CNContactBirthdayKey)
        }

        if includeOrganization ?? true {
            keysToFetch.append(CNContactOrganizationNameKey)
            keysToFetch.append(CNContactJobTitleKey)
        }

        //Get all the containers
        var allContainers: [CNContainer] = []
        allContainers = try contactStore.containers(matching: nil)


        var results: [CNContact] = []

        // Iterate all containers and append their contacts to our results array
        for container in allContainers {

            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)

            let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
            
            results.append(contentsOf: containerResults)
        }

        return results
    }
}


