#include <IOKit/IOLib.h>
#include "foohid_device.h"
#include "debug.h"

#define super IOHIDDevice
OSDefineMetaClassAndStructors(com_uvoglu_tdmfoohid_device, IOHIDDevice)

bool com_uvoglu_tdmfoohid_device::init(OSDictionary *dict) {
    LogD("Initializing a new virtual HID device.");
    
    if (!super::init(dict)) {
        return false;
    }
    
    if (isMouse) {
        setProperty("HIDDefaultBehavior", "Mouse");
    } else if (isKeyboard) {
        setProperty("HIDDefaultBehavior", "Keyboard");
    }
    
    return true;
}

bool com_uvoglu_tdmfoohid_device::start(IOService *provider) {
    LogD("Executing 'com_uvoglu_tdmfoohid_device::start()'.");
    return super::start(provider);
}

void com_uvoglu_tdmfoohid_device::stop(IOService *provider) {
    LogD("Executing 'com_uvoglu_tdmfoohid_device::stop()'.");
    
    super::stop(provider);
}

void com_uvoglu_tdmfoohid_device::free() {
    LogD("Executing 'com_uvoglu_tdmfoohid_device::free()'.");
    
    if (reportDescriptor) IOFree(reportDescriptor, reportDescriptor_len);
    if (m_name) m_name->release();
    if (m_serial_number_string) m_serial_number_string->release();
    
    super::free();
}

OSString *com_uvoglu_tdmfoohid_device::name() {
    return m_name;
}

void com_uvoglu_tdmfoohid_device::subscribe(IOService *userClient) {
    m_user_client = OSDynamicCast(com_uvoglu_tdmfoohid_userclient, userClient);
}

void com_uvoglu_tdmfoohid_device::setName(OSString *name) {
    if (name) name->retain();
    m_name = name;
}

void com_uvoglu_tdmfoohid_device::setSerialNumberString(OSString *serialNumberString) {
    if (serialNumberString) {
        serialNumberString->retain();
    }
    
    m_serial_number_string = serialNumberString;
}

void com_uvoglu_tdmfoohid_device::setVendorID(uint32_t vendorID) {
    m_vendor_id = OSNumber::withNumber(vendorID, 32);
}

void com_uvoglu_tdmfoohid_device::setProductID(uint32_t productID) {
    m_product_id = OSNumber::withNumber(productID, 32);
}

IOReturn com_uvoglu_tdmfoohid_device::newReportDescriptor(IOMemoryDescriptor **descriptor) const {
    LogD("Executing 'com_uvoglu_tdmfoohid_device::newReportDescriptor()'.");
    IOBufferMemoryDescriptor *buffer =
        IOBufferMemoryDescriptor::inTaskWithOptions(kernel_task, 0, reportDescriptor_len);
    
    if (!buffer) {
        LogD("Error while allocating new IOBufferMemoryDescriptor.");
        return kIOReturnNoResources;
    }
    
    buffer->writeBytes(0, reportDescriptor, reportDescriptor_len);
    *descriptor = buffer;
    
    return kIOReturnSuccess;
}

IOReturn com_uvoglu_tdmfoohid_device::setReport(IOMemoryDescriptor *report, IOHIDReportType reportType, IOOptionBits options) {
    // No one is listening yet.
    if (!m_user_client) return kIOReturnSuccess;

    return m_user_client->notifySubscriber(report);
}

OSString *com_uvoglu_tdmfoohid_device::newProductString() const {
    m_name->retain();
    return m_name;
}

OSString *com_uvoglu_tdmfoohid_device::newSerialNumberString() const {
    m_serial_number_string->retain();
    return m_serial_number_string;
}

OSNumber *com_uvoglu_tdmfoohid_device::newVendorIDNumber() const {
    m_vendor_id->retain();
    return m_vendor_id;
}

OSNumber *com_uvoglu_tdmfoohid_device::newProductIDNumber() const {
    m_product_id->retain();
    return m_product_id;
}
