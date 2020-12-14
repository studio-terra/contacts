declare module "@capacitor/core" {
  interface PluginRegistry {
    Contacts: ContactsPlugin;
  }
}
export interface PermissionStatus {
  granted: boolean;
}

export interface PhoneNumber {
  label?: string;
  number?: string;
}

export interface EmailAddress {
  label?: string;
  address?: string;
}

export interface Contact {
  contactId: string;
  displayName?: string;
  photoThumbnail?: string;
  phoneNumbers: PhoneNumber[];
  emails: EmailAddress[];
  birthday?: string;
  organizationName?: string;
  organizationRole?: string;
}

export interface QueryOptions {
  includeEmails: boolean;
  includePhones: boolean;
  includeThumbnail: boolean;
  includeBirthday: boolean;
  includeOrganization: boolean;
  hasPhone?: boolean;
  isInVisibleGroup?: boolean;
}

export interface ContactsPlugin {
  getPermissions(): Promise<PermissionStatus>;
  getContacts(options?: QueryOptions): Promise<{ contacts: Contact[] }>;
}
