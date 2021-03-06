/*
 * Copyright (C) 2011 Philippe Gerum <rpm@xenomai.org>.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA.
 */
#ifndef _COBALT_SH_ASM_UAPI_ARITH_H
#define _COBALT_SH_ASM_UAPI_ARITH_H

#include <asm/xenomai/uapi/features.h>

#define xnarch_add96and64(l0, l1, l2, s0, s1)		\
	do {						\
		__asm__ ("clrt\n\t"			\
			 "addc %4, %2\n\t"		\
			 "addc %3, %1\n\t"		\
			 "addc %5, %0\n\t"		\
			 : "+r"(l0), "+r"(l1), "+r"(l2)	\
			 : "r"(s0), "r"(s1), "r" (0) : "t");	\
	} while (0)

#include <cobalt/uapi/asm-generic/arith.h>

#endif /* _COBALT_SH_ASM_UAPI_ARITH_H */
