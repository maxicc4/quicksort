#include "Cache.h"
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <math.h>
//DATO
#define VIAS 4

//DATO
#define BLOCK_SIZE 64

//OFFSET_BITS = LOG BASE 2 (BLOCK_SIZE) 
#define OFFSET_BITS 6

//SETS = 4KB/(VIAS*BLOCK_SIZE)
#define SETS 16
//INDEX_BITS = LOG BASE 2 (SETS)
#define INDEX_BITS 4

//DATO
#define ADD_SPACE 16

//BLOCKS = (2^ADD_SPACE)/BLOCK_SIZE
#define BLOCKS 1024


typedef struct{
    char data[BLOCK_SIZE];
    int tag;
    int last_use;
    bool dirty;
    bool valid;
} Cache_Slot;

static Cache_Slot cache_mem [SETS][VIAS]; 
static char ppal_mem [BLOCKS][BLOCK_SIZE];
static size_t misses;
static size_t accesos;

void iniciar_slot(Cache_Slot* slot){
    slot->valid = false;
    slot->last_use = 0;
}

void init(){
    for (int i=0 ; i<SETS ; i++){
        for (int j=0 ; j<VIAS ; j++){
            iniciar_slot(&cache_mem[i][j]);
        }
    }
    misses = 0;
    accesos = 0;
}

void aumentar_last_use(int set){
    for (int i = 0 ; i<VIAS ; i++){
        cache_mem[set][i].last_use+=1;
    }
}

int find_set(int address){
    int set = (address << (ADD_SPACE - OFFSET_BITS)) % SETS;
    return set;
}

int find_lru(int set){
    int lru = 0;
    int last_use = 0;
    for (int i = 0 ; i<VIAS ; i++){
        if (!cache_mem[set][i].valid){
            return i;
        }
        if (cache_mem[set][i].last_use > last_use){
            lru = i;
            last_use = cache_mem[set][i].last_use;
        }
    }
    return lru;
}

int is_dirty(int way, int setnum){
    if (!cache_mem[setnum][way].valid) return false;
    return cache_mem[setnum][way].dirty;
}

void read_block(int blocknum){
    int set = blocknum % SETS;
    int lru = find_lru(set);
    if (is_dirty(lru,set)){
        write_block(lru,set);
    }
    Cache_Slot* slot = &cache_mem[set][lru];
    memcpy(slot->data,ppal_mem[blocknum],BLOCK_SIZE);
    slot->dirty = false;
    slot->valid = true;
    slot->tag = blocknum >> INDEX_BITS;
    slot->last_use = 0;
}

int slot_to_blocknum(int tag, int setnum){
    int blocknum = tag << INDEX_BITS;
    blocknum += setnum;
    return blocknum;
}

void write_block(int way, int setnum){
    Cache_Slot* slot = &cache_mem[setnum][way];
    if (!slot->valid) return;
    int blocknum = slot_to_blocknum(slot->tag,setnum);
    memcpy(ppal_mem[blocknum],slot->data,BLOCK_SIZE);
    slot->dirty = false;
    slot->last_use = 0;
}

int add_to_blocknum(int address){
    return address >> OFFSET_BITS;
}

int add_to_tag(int address){
    return address >> (OFFSET_BITS + INDEX_BITS);
}

int add_to_set(int address){
    return (address >> OFFSET_BITS) % SETS;
}

int add_to_offset(int address){
    return address % BLOCK_SIZE;
}

int read_byte(int address){
    int tag = add_to_tag(address);
    int set = add_to_set(address);
    int offset = add_to_offset(address);
    aumentar_last_use(set);
    for (int i = 0; i<VIAS ; i++){
        if ((cache_mem[set][i].valid) && (cache_mem[set][i].tag == tag)){
            accesos += 1;
            cache_mem[set][i].last_use = 0;
            return (unsigned int) cache_mem[set][i].data[offset];
        }
    }
    misses+=1;
    accesos+=1;
    int blocknum = add_to_blocknum(address);
    read_block(blocknum);
    return (unsigned int) ppal_mem[blocknum][offset];
}


int write_byte(int address, char value){
    int tag = add_to_tag(address);
    int set = add_to_set(address);
    int offset = add_to_offset(address);
    aumentar_last_use(set);

    for (int i = 0; i<VIAS ; i++){
        if ((cache_mem[set][i].valid) && cache_mem[set][i].tag == tag){
            cache_mem[set][i].data[offset] = value;
            cache_mem[set][i].dirty = true;
            aumentar_last_use(set);
            cache_mem[set][i].last_use = 0;
            accesos+=1;
            return (unsigned int) value;
        }
    }
    int lru = find_lru(set);
    int blocknum = add_to_blocknum(address);
    read_block(blocknum);
    cache_mem[set][lru].data[offset] = value;
    cache_mem[set][lru].dirty = true;
    accesos+=1;
    misses+=1;
    return value;
}

int get_miss_rate(){
    return roundf(((float)misses/accesos)*100);
}

