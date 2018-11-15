#ifndef foohid_userclient_h
#define foohid_userclient_h

#include <IOKit/IOService.h>
#include <IOKit/IOUserClient.h>

#include "foohid.h"

/**
 The goal of this User Client is to expose to user space the following selector.
*/
enum {
    com_uvoglu_tdmfoohid_method_create,
    com_uvoglu_tdmfoohid_method_destroy,
    com_uvoglu_tdmfoohid_method_send,
    com_uvoglu_tdmfoohid_method_list,
    com_uvoglu_tdmfoohid_method_subscribe,

    com_uvoglu_tdmfoohid_method_count  // Keep track of the length of this enum.
};

class com_uvoglu_tdmfoohid_userclient : public IOUserClient {
    OSDeclareDefaultStructors(com_uvoglu_tdmfoohid_userclient);
    
public:
    virtual bool initWithTask(task_t owningTask, void *securityToken,
                              UInt32 type, OSDictionary *properties) override;
    
    virtual bool start(IOService *provider) override;
    virtual void stop(IOService *provider) override;
    
    virtual IOReturn externalMethod(uint32_t selector,
                                    IOExternalMethodArguments *arguments,
                                    IOExternalMethodDispatch *dispatch,
                                    OSObject *target, void *reference) override;

    virtual IOReturn notifySubscriber(IOMemoryDescriptor *report);

protected:
    /**
     * The following methods unpack/handle the given arguments and 
     * call the related driver method.
     */
    virtual IOReturn methodCreate(IOExternalMethodArguments *arguments);
    virtual IOReturn methodDestroy(IOExternalMethodArguments *arguments);
    virtual IOReturn methodSend(IOExternalMethodArguments *arguments);
    virtual IOReturn methodList(IOExternalMethodArguments *arguments);
    virtual IOReturn methodSubscribe(IOExternalMethodArguments *arguments);

    /**
     *  The following static methods redirect the call to the 'target' instance.
     */
    static IOReturn sMethodCreate(com_uvoglu_tdmfoohid_userclient *target,
                                 void *reference,
                                 IOExternalMethodArguments *arguments);
    static IOReturn sMethodDestroy(com_uvoglu_tdmfoohid_userclient *target,
                                  void *reference,
                                  IOExternalMethodArguments *arguments);
    static IOReturn sMethodSend(com_uvoglu_tdmfoohid_userclient *target,
                               void *reference,
                               IOExternalMethodArguments *arguments);
    static IOReturn sMethodList(com_uvoglu_tdmfoohid_userclient *target,
                               void *reference,
                               IOExternalMethodArguments *arguments);
    static IOReturn sMethodSubscribe(com_uvoglu_tdmfoohid_userclient *target,
                                    void *reference,
                                    IOExternalMethodArguments *arguments);

private:
    /**
     *  Method dispatch table.
     */
    static const IOExternalMethodDispatch s_methods[com_uvoglu_tdmfoohid_method_count];
    
    /**
     *  Driver provider.
     */
    com_uvoglu_tdmfoohid *m_hid_provider;

    /**
     *  Userland subscriber.
     */
    OSAsyncReference64 *m_subscriber = nullptr;
    
    /**
     *  Task owner.
     */
    task_t m_owner;
};

#endif
