/* Orx - Portable Game Engine
 *
 * Orx is the legal property of its developers, whose names
 * are listed in the COPYRIGHT file distributed
 * with this source distribution.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

/**
 * @file orxTest.m
 * @date 28/01/2010
 * @author iarwain@orx-project.org
 *
 * iPhone test executable
 *
 */


#include "orx.h"

static orxOBJECT *spstGenerator;

static orxSTATUS orxFASTCALL EventHandler(const orxEVENT *_pstEvent)
{
  orxSTATUS eResult = orxSTATUS_SUCCESS;
  
  /* Checks */
  orxASSERT(_pstEvent->eType == orxEVENT_TYPE_PHYSICS);

  /* Going out of world? */
  if(_pstEvent->eID == orxPHYSICS_EVENT_OUT_OF_WORLD)
  {
    /* Asks for corresponding object deletion */
    orxObject_SetLifeTime(orxOBJECT(_pstEvent->hSender), orxFLOAT_0);
  }
  /* Colliding? */
  else if(_pstEvent->eID == orxPHYSICS_EVENT_CONTACT_ADD)
  {
    /* Adds bump FX on both objects */
    orxObject_AddUniqueFX(orxOBJECT(_pstEvent->hSender), "Bump");
    orxObject_AddUniqueFX(orxOBJECT(_pstEvent->hRecipient), "Bump");
  }
  
  /* Done! */
  return eResult;
}

static void orxFASTCALL Update(const orxCLOCK_INFO *_pstClockInfo, void *_pstContext)
{
  /* Has Generator? */
  if(spstGenerator)
  {
    orxVECTOR vMousePos;

    /* Gets mouse position in world space */
    if(orxRender_GetWorldPosition(orxMouse_GetPosition(&vMousePos), &vMousePos))
    {
      /* Updates its Z coord */
      vMousePos.fZ += orxFLOAT_1;

      /* Updates its position */
      orxObject_SetPosition(spstGenerator, &vMousePos);

      /* Updates its status */
      orxObject_Enable(spstGenerator, orxInput_IsActive("Spawn"));
    }
  }
}

static void orxFASTCALL Log(const orxCLOCK_INFO *_pstInfo, void *_pContext)
{
  /* Addes a new timer */
  orxClock_AddGlobalTimer(Log, orxFLOAT_1, 1, (void *)!(orxBOOL)_pContext);

  /* Tic/Tac */
  orxLOG("%s (FPS = %ld)", _pContext ? "Tic!" : "Tac!", orxFPS_GetFPS());
}

static orxSTATUS orxFASTCALL Init()
{
  /* Creates viewport */
  orxViewport_CreateFromConfig("Viewport");

  /* Creates generator */
  spstGenerator = orxObject_CreateFromConfig("Generator");

  /* Creates walls */
  orxObject_CreateFromConfig("Walls");

  /* Adds a timer */
  orxClock_AddGlobalTimer(Log, orxFLOAT_1, 1, orxNULL);

  /* Registers callback */
  orxClock_Register(orxClock_FindFirst(orx2F(-1.0f), orxCLOCK_TYPE_CORE), Update, orxNULL, orxMODULE_ID_MAIN, orxCLOCK_PRIORITY_NORMAL);

  /* Registers event handler */
  orxEvent_AddHandler(orxEVENT_TYPE_PHYSICS, EventHandler);

  /* Done! */
  return orxSTATUS_SUCCESS;
}

static orxSTATUS orxFASTCALL Run()
{
  return orxSTATUS_SUCCESS;
}

static void orxFASTCALL Exit()
{
}

int main(int argc, char *argv[])
{
  /* Launches application */
  orx_Execute(argc, argv, Init, Run, Exit);

  /* Done! */
  return EXIT_SUCCESS;
}