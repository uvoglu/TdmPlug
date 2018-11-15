#ifndef foohid_types_h
#define foohid_types_h

const uint8_t foohid_max_report = 64;

typedef struct foohid_report {
    uint64_t size;
    uint8_t data[foohid_max_report];
} foohid_report;

#endif
