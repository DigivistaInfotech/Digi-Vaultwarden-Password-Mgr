export type VaultRole = "owner" | "admin" | "manager" | "user" | "home" | "teen" | "family";

export interface PermissionPolicy {
  canManageOrganization: boolean;
  canManageMembers: boolean;
  canViewAssignedCollections: boolean;
  canEditAssignedCollections: boolean;
  canViewPersonalVault: boolean;
  canViewAnotherUsersPersonalVault: false;
  dashboardMode: "professional" | "home" | "teen" | "family";
}

export const permissionPolicies: Record<VaultRole, PermissionPolicy> = {
  owner: {
    canManageOrganization: true,
    canManageMembers: true,
    canViewAssignedCollections: true,
    canEditAssignedCollections: true,
    canViewPersonalVault: true,
    canViewAnotherUsersPersonalVault: false,
    dashboardMode: "professional"
  },
  admin: {
    canManageOrganization: false,
    canManageMembers: true,
    canViewAssignedCollections: true,
    canEditAssignedCollections: true,
    canViewPersonalVault: true,
    canViewAnotherUsersPersonalVault: false,
    dashboardMode: "professional"
  },
  manager: {
    canManageOrganization: false,
    canManageMembers: false,
    canViewAssignedCollections: true,
    canEditAssignedCollections: true,
    canViewPersonalVault: true,
    canViewAnotherUsersPersonalVault: false,
    dashboardMode: "professional"
  },
  user: {
    canManageOrganization: false,
    canManageMembers: false,
    canViewAssignedCollections: true,
    canEditAssignedCollections: false,
    canViewPersonalVault: true,
    canViewAnotherUsersPersonalVault: false,
    dashboardMode: "professional"
  },
  home: {
    canManageOrganization: false,
    canManageMembers: false,
    canViewAssignedCollections: false,
    canEditAssignedCollections: false,
    canViewPersonalVault: true,
    canViewAnotherUsersPersonalVault: false,
    dashboardMode: "home"
  },
  teen: {
    canManageOrganization: false,
    canManageMembers: false,
    canViewAssignedCollections: false,
    canEditAssignedCollections: false,
    canViewPersonalVault: true,
    canViewAnotherUsersPersonalVault: false,
    dashboardMode: "teen"
  },
  family: {
    canManageOrganization: false,
    canManageMembers: false,
    canViewAssignedCollections: true,
    canEditAssignedCollections: false,
    canViewPersonalVault: true,
    canViewAnotherUsersPersonalVault: false,
    dashboardMode: "family"
  }
};

export function validatePermissionBoundary(role: VaultRole): boolean {
  return permissionPolicies[role].canViewAnotherUsersPersonalVault === false;
}
