/*
 * get_battery_info.c
 * Retrieves detailed battery information from iOS device via DiagnosticsRelay
 * Compile with: gcc -o get_battery_info get_battery_info.c -limobiledevice-1.0 -lplist-2.0
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libimobiledevice/libimobiledevice.h>
#include <libimobiledevice/lockdown.h>
#include <libimobiledevice/diagnostics_relay.h>
#include <plist/plist.h>

int main(int argc, char *argv[]) {
    idevice_t device = NULL;
    lockdownd_client_t lockdown = NULL;
    diagnostics_relay_client_t diagnostics = NULL;
    lockdownd_service_descriptor_t service = NULL;
    plist_t request = NULL;
    plist_t response = NULL;
    char *xml_output = NULL;
    uint32_t xml_length = 0;
    
    // Connect to device
    if (idevice_new(&device, NULL) != IDEVICE_E_SUCCESS) {
        fprintf(stderr, "ERROR: No device found\n");
        return 1;
    }
    
    // Start lockdown client
    if (lockdownd_client_new_with_handshake(device, &lockdown, "get_battery_info") != LOCKDOWN_E_SUCCESS) {
        fprintf(stderr, "ERROR: Could not connect to lockdownd\n");
        idevice_free(device);
        return 1;
    }
    
    // Start diagnostics relay service
    if (lockdownd_start_service(lockdown, "com.apple.mobile.diagnostics_relay", &service) != LOCKDOWN_E_SUCCESS) {
        fprintf(stderr, "ERROR: Could not start diagnostics relay service\n");
        lockdownd_client_free(lockdown);
        idevice_free(device);
        return 1;
    }
    
    // Create diagnostics relay client
    if (diagnostics_relay_client_new(device, service, &diagnostics) != DIAGNOSTICS_RELAY_E_SUCCESS) {
        fprintf(stderr, "ERROR: Could not create diagnostics relay client\n");
        lockdownd_service_descriptor_free(service);
        lockdownd_client_free(lockdown);
        idevice_free(device);
        return 1;
    }
    
    // Request MobileBatteryInfo (try different names)
    const char* battery_keys[] = {"All", "GasGauge", "IORegistry", NULL};
    int success = 0;
    
    for (int i = 0; battery_keys[i] != NULL && !success; i++) {
        fprintf(stderr, "Trying '%s'...\n", battery_keys[i]);
        if (diagnostics_relay_request_diagnostics(diagnostics, battery_keys[i], &response) == DIAGNOSTICS_RELAY_E_SUCCESS) {
            if (response) {
                fprintf(stderr, "SUCCESS: Got response from '%s'\n", battery_keys[i]);
                // Convert plist to XML for easy parsing
                plist_to_xml(response, &xml_output, &xml_length);
                if (xml_output) {
                    printf("%s", xml_output);
                    free(xml_output);
                }
                plist_free(response);
                response = NULL;
                success = 1;
                break;
            }
        }
    }
    
    if (!success) {
        fprintf(stderr, "ERROR: Failed to request battery diagnostics\n");
    }
    
    // Cleanup
    if (diagnostics) {
        diagnostics_relay_goodbye(diagnostics);
        diagnostics_relay_client_free(diagnostics);
    }
    if (service) {
        lockdownd_service_descriptor_free(service);
    }
    if (lockdown) {
        lockdownd_client_free(lockdown);
    }
    if (device) {
        idevice_free(device);
    }
    
    return 0;
}
