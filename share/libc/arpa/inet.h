/**************************************************************************/
/*                                                                        */
/*  This file is part of TrustInSoft Kernel.                              */
/*                                                                        */
/*  TrustInSoft Kernel is a fork of Frama-C. All the differences are:     */
/*    Copyright (C) 2016-2017 TrustInSoft                                 */
/*                                                                        */
/*  TrustInSoft Kernel is released under GPLv2                            */
/*                                                                        */
/**************************************************************************/

/**************************************************************************/
/*                                                                        */
/*  This file is part of Frama-C.                                         */
/*                                                                        */
/*  Copyright (C) 2007-2015                                               */
/*    CEA (Commissariat à l'énergie atomique et aux énergies              */
/*         alternatives)                                                  */
/*                                                                        */
/*  you can redistribute it and/or modify it under the terms of the GNU   */
/*  Lesser General Public License as published by the Free Software       */
/*  Foundation, version 2.1.                                              */
/*                                                                        */
/*  It is distributed in the hope that it will be useful,                 */
/*  but WITHOUT ANY WARRANTY; without even the implied warranty of        */
/*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         */
/*  GNU Lesser General Public License for more details.                   */
/*                                                                        */
/*  See the GNU Lesser General Public License version 2.1                 */
/*  for more details (enclosed in the file licenses/LGPLv2.1).            */
/*                                                                        */
/**************************************************************************/

#ifndef FC_ARPA_INET
#define FC_ARPA_INET
#include "../inttypes.h"
#include "../netinet/in.h"
#include "../features.h"

__BEGIN_DECLS

/*@ assigns \result \from arg ; */
in_addr_t    inet_addr(const char * arg);
/*@ assigns \result \from arg ; */
char        *inet_ntoa(struct in_addr arg);

/*@ assigns \result \from dst,af,((char*)src)[0..];
  assigns dst[0..size-1] \from af,((char*)src)[0..] ; */
const char  *inet_ntop(int af, const void *src, char *dst,
                 socklen_t size);

/*@ assigns \result \from af,src[..];
  assigns ((char*)dst)[0..] \from af,src[0..] ; */
int          inet_pton(int af, const char *src, void *dst);

__END_DECLS

#endif
